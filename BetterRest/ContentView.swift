//
//  ContentView.swift
//  BetterRest
//
//  Created by Anastasiia Solomka on 30.04.2023.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 0
    
    var calculatedSleepTime: String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60 //number of hours in seconds, because we have Double format from ML model
            let minute = (components.minute ?? 0) * 60 //number of minutes in seconds
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount)) //calculate how much sleep they actually need
            let sleepTime = wakeUp - prediction.actualSleep
            
            return "\(sleepTime.formatted(date: .omitted, time: .shortened))"
                
        } catch {
            return "There was an error"
        }
    }
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("When do you want to wake up?") {
                    DatePicker("Please enter time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                .font(.headline)
                
                Section("Desired amount of sleep") {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.2)
                }
                .font(.headline)
                
                Section("Daily coffee intake") {
                    Picker("Coffee amount", selection: $coffeeAmount) {
                        ForEach(1..<21) {
                            if $0 == 1 {
                                Text("\($0) cup")
                            } else {
                                Text("\($0) cups")
                            }
                        }
                    }
                    /*
                     Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)
                     */
                }
                .font(.headline)
                
                Section("Your perfect bedtime is") {
                    Text("\(calculatedSleepTime)")
                        .font(.largeTitle)
                }
                .font(.headline)
                .foregroundColor(.blue)
                
            }
            .navigationTitle("BetterRest")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
