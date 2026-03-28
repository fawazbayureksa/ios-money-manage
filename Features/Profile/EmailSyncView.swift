import SwiftUI

struct EmailSyncView: View {
    @StateObject private var viewModel = EmailSyncViewModel()

    var body: some View {
        List {
            Section {
                HStack(spacing: 10) {
                    Circle()
                        .fill(viewModel.connected ? .green : .red)
                        .frame(width: 10, height: 10)

                    Text(viewModel.connected ? "Gmail Connected" : "Not Connected")
                        .font(.headline)

                    Spacer()

                    if viewModel.connected {
                        Button("Disconnect", role: .destructive) {
                            Task {
                                await viewModel.disconnect()
                            }
                        }
                        .font(.caption)
                    } else {
                        Button(viewModel.isConnecting ? "Connecting..." : "Connect") {
                            Task {
                                await viewModel.connect()
                            }
                        }
                        .font(.caption)
                        .disabled(viewModel.isConnecting)
                    }
                }
            }

            if viewModel.connected {
                Section {
                    Button {
                        Task {
                            await viewModel.sync()
                        }
                    } label: {
                        HStack {
                            if viewModel.syncing {
                                ProgressView()
                                    .padding(.trailing, 4)
                            }

                            Text(viewModel.syncing ? "Syncing..." : "Sync Now")
                        }
                    }
                    .disabled(viewModel.syncing)

                    if let result = viewModel.syncResult {
                        HStack(spacing: 14) {
                            Label("\(result.imported) imported", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .font(.caption)
                            Label("\(result.skipped) skipped", systemImage: "forward.fill")
                                .foregroundStyle(.orange)
                                .font(.caption)
                            Label("\(result.failed) failed", systemImage: "xmark.circle.fill")
                                .foregroundStyle(.red)
                                .font(.caption)
                        }
                    }
                }
            }

            if !viewModel.logs.isEmpty {
                Section("Sync Logs (\(viewModel.total))") {
                    ForEach(viewModel.logs) { log in
                        EmailSyncLogRow(log: log)
                    }
                }
            } else if !viewModel.isLoading && viewModel.connected {
                Section {
                    Text("No sync logs yet.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if let error = viewModel.errorMessage, !error.isEmpty {
                Section {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .navigationTitle("Email Sync")
        .task {
            await viewModel.loadStatus()
        }
        .refreshable {
            await viewModel.loadStatus(page: viewModel.page, limit: viewModel.limit)
        }
    }
}

private struct EmailSyncLogRow: View {
    let log: EmailSyncLog

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(log.bankName.isEmpty ? "Unknown" : log.bankName)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Spacer()

                EmailSyncStatusBadge(status: log.status)
            }

            if let amount = log.amount, amount > 0 {
                Text(formatCurrency(amount))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text(log.subject)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            if !log.errorMessage.isEmpty {
                Text(log.errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }

    private func formatCurrency(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "id_ID")
        formatter.currencyCode = "IDR"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "Rp \(value)"
    }
}

private struct EmailSyncStatusBadge: View {
    let status: String

    private var color: Color {
        switch status {
        case "imported":
            return .green
        case "skipped":
            return .orange
        case "failed":
            return .red
        default:
            return .gray
        }
    }

    var body: some View {
        Text(status)
            .font(.caption2)
            .fontWeight(.bold)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        EmailSyncView()
    }
}
