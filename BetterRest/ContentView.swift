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
        return Calendar.current.date(from: components) ?? .now
    }

    var body: some View {
        NavigationStack {
            Form {
                VStack(alignment: .leading, spacing: 0) {
                    Text("When do you wake up?")
                        .font(.headline)

                    DatePicker("Please enter a time:", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text("Desired amount of sleep")
                        .font(.headline)

                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text("Daily coffee intake")
                        .font(.headline)

                    Picker("Number of cups", selection: $coffeeAmount) {
                        ForEach(0..<21) { number in
                            Text("\(number) \(number == 1 ? "cup" : "cups")")
                        }
                    }
                    .pickerStyle(.navigationLink)
                }

                // Display the recommended bedtime if calculated
                if !showCalculateButton {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Your ideal bedtime is")
                            .font(.headline)
                        Text(recommendedBedtime)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                           // .padding()
                    }
                }
            }
            .navigationTitle("BetterRest")
            .toolbar {
                if showCalculateButton {
                    Button("Calculate", action: calculateBedtime)
                }
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
        }
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
            let minute = (components.minute ?? 0) * 60
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))

            let sleepTime = wakeUp - prediction.actualSleep
            recommendedBedtime = sleepTime.formatted(date: .omitted, time: .shortened)
            showCalculateButton = false
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry there was a problem calculating your bedtime."
            showingAlert = true
        }
    }
}

#Preview {
    ContentView()
}

