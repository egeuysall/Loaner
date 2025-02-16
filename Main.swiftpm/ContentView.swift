import SwiftUI

struct ContentView: View {
    @State private var loanAmount: Double = 0.0
    @State private var selectedLoanTerm = 30
    @State private var loanTerms = [10, 15, 20, 30]
    @State private var interestRate: Double = 0.0
    @State private var additionalCosts: Double = 0.0
    @FocusState private var isFocused: Bool
    
    @State private var paymentFrequencies = ["Weekly", "Monthly", "Annually"]
    @State private var selectedPaymentFrequency = "Monthly"
    
    private let frequencyMap: [String: Double] = [
        "Weekly": 52,
        "Monthly": 12,
        "Annually": 1
    ]
    
    var finalResult: Double {
        let loan = loanAmount
        let interest = interestRate / 100
        let loanTerm = Double(selectedLoanTerm)
        let frequencyOfPayment = frequencyMap[selectedPaymentFrequency] ?? 12
        
        let ratePerPeriod = interest / frequencyOfPayment
        let totalPayments = loanTerm * frequencyOfPayment
        
        let numerator = ratePerPeriod * pow(1 + ratePerPeriod, totalPayments)
        let denominator = pow(1 + ratePerPeriod, totalPayments) - 1
        let baseMortgage = (numerator / denominator) * loan
        
        let adjustedAdditionalCosts = additionalCosts / frequencyOfPayment
        let totalPayment = baseMortgage + adjustedAdditionalCosts
        
        return totalPayment.isFinite ? totalPayment : 0
    }
    
    var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = Locale.current.currency?.identifier ?? "USD"
        return formatter
    }
    
    private var percentFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        return formatter
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Loan Amount") {
                    TextField("Loan amount", value: $loanAmount, formatter: currencyFormatter)
                        .keyboardType(.decimalPad)
                        .focused($isFocused)
                }
                
                Section("Loan Term") {
                    Picker("Loan term", selection: $selectedLoanTerm) {
                        ForEach(loanTerms, id: \.self) { term in
                            Text("\(term) years")
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Interest Rate") {
                    TextField("Interest rate", value: $interestRate, formatter: percentFormatter)
                        .keyboardType(.decimalPad)
                        .focused($isFocused)
                }
                
                Section("Payment Frequency") {
                    Picker("Payment frequency", selection: $selectedPaymentFrequency) {
                        ForEach(paymentFrequencies, id: \.self) { term in
                            Text(term)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Additional Costs") {
                    TextField("Additional costs", value: $additionalCosts, formatter: currencyFormatter)
                        .keyboardType(.decimalPad)
                        .focused($isFocused)
                }
                
                Section("Estimated Payment") {
                    Text(finalResult, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        .contextMenu {
                            Button(action: {
                                UIPasteboard.general.string = String(format: "%.2f", finalResult)
                            }) {
                                Text("Copy")
                                Image(systemName: "doc.on.clipboard")
                            }
                        }
                }
            }
            .navigationTitle("Loaner")
            .toolbar{
                if isFocused {
                    Button("Done") {
                        isFocused = false
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.roundedRectangle)
                    .accentColor(.blue)
                }
            }
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
}
