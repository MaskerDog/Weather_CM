//
//  HTTPCommunication.swift
//  Weather_CM
//
//  Created by npc on 2022/01/05.
//

import Foundation

class Fetcher {
    /// インスタンスはつくらせない
    private init() {}
    
    enum FetchError: Error {
        case networkError
        case statusError
    }
    /// GETで特別な設定のない通常のJSON取得処理ならばこちらを呼ぶ
    /// 処理の結果、成功か失敗かはここではわからないのでhandler側で対応する
    ///
    /// - Parameters:
    ///   - url: 取得したいJSONのURL。パラメータは付与された状態で渡すこと
    ///   - session: 指定がない場合はnil。
    ///   - handler: データを取得後の処理
    /// - Returns: データとエラーステータス
    static func fetch(from url: URL, session: URLSession? = nil) async -> Result<Data, Error> {

        // リクエストを作成してfetch(from:session:handler:)に投げる
        let request = URLRequest(url: url)
        return await self.fetch(from: request, session: session)

    }


    /// URLRequestの指定がある場合（POST送信など）はこちらを呼ぶ
    /// 処理の結果、失敗かどうかはResultで判定する
    ///
    /// - Parameters:
    ///   - request: 設定済みのrequest
    ///   - session: 指定がない場合はnil。
    ///   - handler: データ取得後の処理
    /// - Returns: データとエラーステータス
    static func fetch(from request: URLRequest, session: URLSession? = nil) async -> Result<Data, Error> {
        let session = (session == nil) ? URLSession(configuration: .default) : session!

        do {
            // awaitを使う 非同期（別スレッド）で実行中
            let (data, response) = try await session.data(for: request)

            guard let response = response as? HTTPURLResponse else {
                return .failure(FetchError.networkError)
            }

            if !(200...299).contains(response.statusCode) {
                print("ステータスコードが正常ではありません： \(response.statusCode)")
                return .failure(FetchError.statusError)
            }

            return .success(data)
        } catch(let error) {
            return .failure(error)
        }
    }

}
