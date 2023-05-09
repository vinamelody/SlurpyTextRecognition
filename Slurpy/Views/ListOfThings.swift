import SwiftUI

struct ListOfThings: View {
  
  @EnvironmentObject var dataStore: DataStore
  
    var body: some View {
      List {
        ForEach(dataStore.collectedItems, id: \.id) { item in
          HStack {
            Label(item.string ?? "<No text>", systemImage: item.icon)
            Spacer()
            ShareLink(item: item.string ?? "") {
              Label("", systemImage: "square.and.arrow.up")
            }
          }
        }
        .onDelete { indexset in
          if let index = indexset.first {
            let item = dataStore.collectedItems[index]
            dataStore.deleteItem(item)
          }
        }
      }
    }
}

struct ListOfThings_Previews: PreviewProvider {
    static var previews: some View {
        ListOfThings()
    }
}
