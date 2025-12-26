//
//  AuraQuizApp.swift
//  AuraQuiz
//
//  Created by José Manuel Jiménez Rodríguez on 25/12/25.
//

import SwiftUI

@main
struct AuraQuizApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                // Forzamos un tamaño mínimo para que quepa todo sin scroll
                .frame(minWidth: 900, minHeight: 700)
                // Color de fondo para toda la ventana (evita bordes blancos al estirar)
                .background(Color(red: 0.05, green: 0.07, blue: 0.12))
        }
        //  Esto quita la barra de título estándar y deja que el contenido mande
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
