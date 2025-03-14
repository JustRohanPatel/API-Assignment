//
//  ContentView.swift
//  API Assignment
//
//  Created by Rohan Patel on 3/4/25.
//
import SwiftUI

struct ContentView: View { //defines a Swift struct
    @State private var competitions = [Competition]() //create var
    @State private var showingAlert = false //dosent spam the alert button

    var body: some View { //defines the body of a view
        NavigationView { //enables navigation between views
            List(competitions, id: \.id) { competition in
                NavigationLink(destination: CompetitionDetailView(competition: competition)) { // sends code to below struct to detail it
                    Text(competition.name)//displays the name of a competition as a text label
                }
            }
            .navigationTitle("Football Competitions") //shows the title
        }
        .task { //loading data from an API
            await loadData()
        }
        .alert(isPresented: $showingAlert) { //when code dosent work the alert opotion
            Alert(title: Text("Loading Error"), message: Text("There was an error loading the football competitions. Please try again later."))// show the writing
        }
    }

    func loadData() async { //finds data
        let query = "https://api.football-data.org/v4/competitions" // the link to the API
        guard let url = URL(string: query) else { return }  //checks if query is a valid URL

        do {
            let (data, _) = try await URLSession.shared.data(from: url)//fetches data from a URL
            let decodedResponse = try JSONDecoder().decode(Competitions.self, from: data)//decodes JSON data into a Swift object
            DispatchQueue.main.async {
                competitions = decodedResponse.competitions //updates the competitions variable
            }
        } catch {
            DispatchQueue.main.async {//updating the UI if alert wrong
                showingAlert = true
            }
        }
    }
}

struct CompetitionDetailView: View { //displays details about a Competition
    var competition: Competition//declares a stored property

    var body: some View { //defines the body of a view
        VStack {
            Text(competition.name).font(.title).padding() // displays the property
            Text("Area").font(.caption)//show where the place is
            Text(competition.area.name)//displays the name of the area
            if let url = competition.emblem, let imageUrl = URL(string: url) { // loads message
                AsyncImage(url: imageUrl) //displays an image
                    .padding()
            }
            Spacer()//put space
        }
        .navigationTitle(competition.name) //sets the navigation bar title
    }
}

#Preview { //makes canvas
    ContentView()
}

struct Area: Codable { //defines a Swift struct
    var name: String//  declares a stored property n
    var flag: String?//declares an optional stored property
}

struct Competition: Identifiable, Codable {//defines a Competition struct
    var id: Int// declares a stored property named id
    var name: String//declares a stored property
    var emblem: String?//declares an optional stored property
    var area: Area//declares a stored property
}

struct Competitions: Codable {// defines a struct
    var competitions: [Competition] //declares a stored propert
}
