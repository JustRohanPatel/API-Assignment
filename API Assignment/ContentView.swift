//
//  ContentView.swift
//  API Assignment
//
//  Created by Rohan Patel on 3/4/25.
//
import SwiftUI

struct ContentView: View {
    @State private var competitions = [Competition]()
    @State private var showingAlert = false

    var body: some View {
        NavigationView {
            List(competitions, id: \.id) { competition in
                NavigationLink(destination: CompetitionDetailView(competition: competition)) {
                    Text(competition.name)
                }
            }
            .navigationTitle("Football Competitions")
        }
        .task {
            await loadData()
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Loading Error"), message: Text("There was an error loading the football competitions. Please try again later."))
        }
    }

    func loadData() async {
        let query = "https://api.football-data.org/v4/competitions"
        guard let url = URL(string: query) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedResponse = try JSONDecoder().decode(Competitions.self, from: data)
            DispatchQueue.main.async {
                competitions = decodedResponse.competitions
            }
        } catch {
            DispatchQueue.main.async {
                showingAlert = true
            }
        }
    }
}

struct CompetitionDetailView: View {
    var competition: Competition

    var body: some View {
        VStack {
            Text(competition.name).font(.title).padding()
            Text("Area").font(.caption)
            Text(competition.area.name)
            if let url = competition.emblem, let imageUrl = URL(string: url) {
                AsyncImage(url: imageUrl)
                    .padding()
            }
            Spacer()
        }
        .navigationTitle(competition.name)
    }
}

#Preview {
    ContentView()
}

struct Area: Codable {
    var name: String
    var flag: String?
}

struct Competition: Identifiable, Codable {
    var id: Int
    var name: String
    var emblem: String?
    var area: Area
}

struct Competitions: Codable {
    var competitions: [Competition]
}
