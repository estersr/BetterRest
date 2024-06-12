//
//  ContentView.swift
//  BetterRest
//
//  Created by Esther Ramos on 12/06/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        //f we just wanted the time from a date we would write this:
        Text(Date.now, format: .dateTime.hour().minute())
            .padding()
        //if we wanted the day, month, and year, we would write this:
        Text(Date.now, format: .dateTime.day().month().year())
            .padding()
        // the formatted() method directly on dates, passing in configuration options for how we want both the date and the time to be formatted
        Text(Date.now.formatted(date: .long, time: .shortened))
    }
    
    func exampleDates() {
        //        var components = DateComponents()
        //        components.hour = 8
        //        components.minute = 0
        //        let date = Calendar.current.date(from: components) ?? .now
        //    }
        let components = Calendar.current.dateComponents([.hour, .minute], from: .now)
        let hour = components.hour ?? 0
        let minute = components.minute ?? 00
    }
}

#Preview {
    ContentView()
}
