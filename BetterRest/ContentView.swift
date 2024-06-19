//
//  BetterRestApp.swift
//  BetterRest
//
//  Created by Esther Ramos on 12/06/24.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime {
        didSet {
            resetCalculation()
        }
    }
    @State private var sleepAmount = 8.0 {
        didSet {
            resetCalculation()
        }
    }
    @State private var coffeeAmount = 1 {
        didSet {
            resetCalculation()
        }
    }
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    @State private var recommendedBedtime = ""
    @State private var showCalculateButton = true

    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }

    var body: some View {
        NavigationStack {
                Form {
                    Section(header: Text("When do you wake up?")) {
                        DatePicker("Please enter a time:", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                    
                    Section(header: Text("Desired amount of sleep")) {
                        Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                    }
                    
                    Section(header: Text("Daily coffee intake")) {
                        Picker("Number of cups", selection: $coffeeAmount) {
                            ForEach(0..<21) { number in
                                Text("\(number) \(number == 1 ? "cup" : "cups")")
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                    
                    // Display the recommended bedtime if calculated
                    if !showCalculateButton {
                        Section(header: Text("Your ideal bedtime is")) {
                            Text(recommendedBedtime)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
                    }
                }
                
                .navigationTitle("BetterRest")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if showCalculateButton {
                            Button("Calculate") {
                                calculateBedtime()
                            }
                        }
                    }
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
        }
        .foregroundColor(.pink)
    }

    func resetCalculation() {
        showCalculateButton = true
        recommendedBedtime = ""
    }

    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)

            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60
            let minute = (components.minute ?? 0)
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))

            let sleepTime = wakeUp - prediction.actualSleep
            recommendedBedtime = sleepTime.formatted(date: .omitted, time: .shortened)
            showCalculateButton = false
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
            showingAlert = true
        }
    }
}


#Preview {
    ContentView()
}

