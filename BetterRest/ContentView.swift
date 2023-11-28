//
//  ContentView.swift
//  BetterRest
//
//  Created by Tes on 03/11/2023.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State private var wakeUp = Date.now
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
        VStack {
            NavigationStack {
                VStack {
                    Text("When do you want to wake up?")
                        .font(.headline)

                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()

                    Text("Desired amount of sleep")
                        .font(.headline)
                    Stepper("\(sleepAmount.formatted())", value: $sleepAmount, in: 4...12, step: 0.5)
                    
                    Text("Daily coffee intake")
                        .font(.headline)
                    Stepper("\(coffeeAmount) cup(s)", value: $coffeeAmount, in: 1...20, step: 1)
                }
                .navigationTitle("BetterRest")
                .toolbar{
                    Button("Calculate") { calculateBedtime()}
                }
                .alert(alertTitle, isPresented: $showingAlert) {
                    Button("ok") {}
                } message: {
                    Text(alertMessage)
                }
                .padding()
            }
        }
    }
    
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            let component = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (component.hour ?? 0) * 60 * 60
            let minute = (component.minute ?? 0) * 60
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was an error calculating your bed time."
        }
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
