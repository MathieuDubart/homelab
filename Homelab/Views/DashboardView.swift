//
//  DashboardView.swift
//  Homelab
//
//  Created by Mathieu Dubart on 18/03/2026.
//

import SwiftUI

struct DashboardView: View {
    @AppStorage("glances_url", store: UserDefaults(suiteName: "group.fr.mathieu-dubart.homelab"))
    private var glancesUrl: String = ""
    @AppStorage("coolify_token", store: UserDefaults(suiteName: "group.fr.mathieu-dubart.homelab")) private var coolifyToken: String = ""
    @AppStorage("coolify_url", store: UserDefaults(suiteName: "group.fr.mathieu-dubart.homelab")) private var coolifyUrl: String = ""
    
    @State private var viewModel: DashboardViewModel?
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if glancesUrl.isEmpty || glancesUrl == "https://" {
                        setupRequiredView
                    } else if let vm = viewModel {
                        Text(LocalizedStringResource.systemTitle)
                            .font(.headline)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: columns, spacing: 16) {
                            StatCardView(
                                title: "CPU",
                                value: String(format: "%.1f", vm.cpuUsage),
                                systemImage: "cpu",
                                color: .indigo,
                                progress: vm.cpuUsage / 100
                            )
                            
                            StatCardView(
                                title: "RAM",
                                value: String(format: "%.0f", vm.ramUsage),
                                systemImage: "memorychip",
                                color: .green,
                                progress: vm.ramUsage / 100
                            )
                        }
                        .padding(.horizontal)
                        
                        Text(LocalizedStringResource.servicesTitle)
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.top, 10)
                        
                        if vm.sortedContainers.isEmpty && !vm.isLoading {
                            Text(LocalizedStringResource.noContainerAvailable)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(vm.sortedContainers) { container in
                                    ContainerRow(container: container)
                                        .padding()
                                        .background(Color(.secondarySystemGroupedBackground))
                                        .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal)
                        }
                    } else {
                        ProgressView(LocalizedStringResource.initialisation)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(LocalizedStringResource.systemMonitorTitle)
            .refreshable { await viewModel?.fetchData() }
            .onAppear { refreshViewModel() }
        }
    }
    
    private var setupRequiredView: some View {
        VStack(spacing: 16) {
            Image(systemName: "server.rack")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text(LocalizedStringResource.checkStatsAtAGlance)
                .font(.headline)
            Text(LocalizedStringResource.enterGlancesUrl)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
        .padding(.horizontal)
    }
    
    private func refreshViewModel() {
        guard !glancesUrl.isEmpty, glancesUrl != "https://" else { return }
        viewModel = DashboardViewModel(host: glancesUrl)
        viewModel?.startMonitoring()
    }
}
