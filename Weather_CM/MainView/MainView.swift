//
//  MainView.swift
//  Weather_CM
//
//  Created by npc on 2022/01/05.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel
    
    init() {
            do {
                viewModel = try MainViewModel()
            } catch {
                fatalError("URLエラー")
            }

        }
    
    var body: some View {
        if let weather = viewModel.weatherResult {
            VStack {
                Text(viewModel.place)
                Text(String(weather.current.temp))
            }
        } else {
            
            Text("hoge")
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
