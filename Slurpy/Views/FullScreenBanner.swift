import SwiftUI

struct FullScreenBanner: View {
  var systemImageName: String
  var mainText: String
  var detailText: String
  var backgroundColor: Color
  
  var body: some View {
    Rectangle()
      .fill(backgroundColor)
      .overlay(
        VStack(spacing: 30) {
          Image(systemName: systemImageName)
            .font(.largeTitle)
          Text(mainText)
            .font(.largeTitle)
            .multilineTextAlignment(.center)
          Text(detailText)
            .font(.body)
            .multilineTextAlignment(.center)
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
        }
          .foregroundColor(.white)
      )
      .edgesIgnoringSafeArea(.all)
  }
}

struct FullScreenBanner_Previews: PreviewProvider {
  static var previews: some View {
    FullScreenBanner(systemImageName: "location.circle", mainText: "Oranges are great", detailText: "Lorem ipsum", backgroundColor: .cyan)
  }
}
