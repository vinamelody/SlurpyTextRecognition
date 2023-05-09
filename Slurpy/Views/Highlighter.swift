import SwiftUI

struct Highlighter: View {
  
  @EnvironmentObject var dataStore: DataStore
  
  var body: some View {
    ForEach(dataStore.allTransientItems) { item in
      RoundedRectangle(cornerRadius: 4)
        .stroke(.pink, lineWidth: 6)
        .frame(width: item.bounds.width, height: item.bounds.height)
        .position(x: item.bounds.minX, y: item.bounds.minY)
        .overlay(
          Image(systemName: item.icon)
            .position(x: item.bounds.minX, y: item.bounds.minY - item.bounds.height / 2 - 20)
            .foregroundColor(.pink)
          )
    }
  }
}

struct Highlighter_Previews: PreviewProvider {
  static var previews: some View {
    Highlighter()
  }
}
