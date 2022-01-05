//
//  OneCall.swift
//  Weather_CM
//
//  Created by npc on 2022/01/05.
//

import Foundation


/// リクエスト用(get送信)
/// ex) https://api.openweathermap.org/data/2.5/onecall?lat={lat}&lon={lon}&exclude={part}&appid={API key}
///
struct RequestOneCall {
    // Geographical coordinates
    /// latitude 緯度 ex)35.39291572 required
    let lat: String
    /// longitude 経度 ex) 139.44288759 requied
    let lon: String
    
    /// API key requied
    let appid: String
    
    /// 除外するデータ optional
    /// 入力する値
    /// current
    /// minutely
    /// hourly
    /// daily
    /// alerts
    let exclude: String?
    
    /// 単位 optional
    /// standard
    /// metric (通常はこれ)
    /// imperial
    /// デフォルトがstandardなのでmetricを指定する
    let units: String?
    
    /// 言語 optional
    let lang: String?
    
    /// latitude, longitude, appidのみ必須
    /// excludeのデフォルトはnil
    /// unitsのデフォルトはmetric
    /// langのデフォルトはja
    init (lat: String, lon: String, appid: String, exclude: String? = nil, units: String? = "metric", lang: String? = "ja"){
        
        self.lat = lat
        self.lon = lon
        self.appid = appid
        self.exclude = exclude
        self.units = units
        self.lang = lang
    }
}

/// レスポンス用(json)
struct ResultOneCall: Decodable {
    // 逆ジオ用
    let lat: Double
    let lon: Double
    
    let current: Current
    struct Current: Decodable {
        /// 計測時間 Unix, UTC
        let dt: Int
        /// 日の出 Unix, UTC
        let sunrise: Int
        /// 日の入り Unix, UTC
        let sunset: Int
        /// 気温
        let temp: Double
        /// 体感温度 風や湿度によって異なる
        let feels_like: Double
    }
}
