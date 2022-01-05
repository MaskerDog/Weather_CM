//
//  MainViewController.swift
//  Weather_CM
//
//  Created by npc on 2022/01/05.
//

import Foundation
import CoreLocation

@MainActor
class MainViewModel: ObservableObject {
    /// ステータス管理用のenum
    enum RequestStatus {
        case unexecuted // 未実行
        case success    // 成功
        case failed     // 失敗
    }
    
    // JSONの受け取りオブジェクト
    var weatherResult: ResultOneCall!
    
    // 場所
    var place: String!
    
    // この値に変更があったら更新する
    // 実行ステータス
    @Published var status: RequestStatus
    
    // エラーが起きうる初期化（雑に作っているので本当はもっときちんとすべき）
    init() throws {
        // 初期化
        weatherResult = nil
        status = .unexecuted
        
        // エラーは呼び出し元で処理してもらう
        try settings()
    }
    
    private func getLocation(from location: CLLocation, completion: @escaping (_ placemark: CLPlacemark) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else { return }
            completion(placemark)
        }
    }
    
    private func settings() throws {
        // URLが正しくないならばエラー
        guard let url = URL(string: OPEN_WEATHER_ENDPOINT + "/" + ONE_CALL) else {
            throw NSError()
        }
        
        // コンポーネントが作られなければエラー
        guard var component = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            throw NSError()
        }
        // パラメータの設定
        let request = RequestOneCall(lat: "35.698389128352", lon: "139.69813269136", appid: APP_ID)
        let mirror = Mirror(reflecting: request)
        
        var queryItems: [URLQueryItem] = []
        
        // よいこはまねしない。リフレクション（Mirror）はあまり使わないようにね
        for child in mirror.children {
            if let label = child.label,
               let value = child.value as? String {
                queryItems.append(URLQueryItem(name: label , value: value))
            } else {
                continue
            }
        }
        
        component.queryItems = queryItems
        
        // コンポーネントからURLが作成できなければエラー
        guard let componentURL = component.url else {
            throw NSError()
        }
        print(componentURL)
        Task {
            // Modelに処理を投げる
            let result = await Fetcher.fetch(from: componentURL)
            switch result {
            case .failure(let error):
                print(error)
                status = .failed
            case .success(let data):
                do {
                    let result = try JSONDecoder().decode(ResultOneCall.self, from: data)
                    weatherResult = result
                    
                    let location = CLLocation(latitude: weatherResult.lat, longitude: weatherResult.lon)
                    getLocation(from: location) { placemark in
                        self.place = placemark.locality
                        // 正常に実行されていたらステータス変更
                        self.status = .success
                    }
                } catch {
                    // 失敗したら失敗のステータスに変更
                    status = .failed
                }
            }
        }
    }
}
