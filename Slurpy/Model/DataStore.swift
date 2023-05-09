/// Copyright (c) 2022 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import Combine

class DataStore: ObservableObject {
  static var shared = DataStore()

  @Published var collectedItems: [StoredItem] = []
  @Published var allTransientItems: [TransientItem] = []

  func keepItem(_ newitem: StoredItem) {
    let index = collectedItems.firstIndex { item in
      item.id == newitem.id
    }

    guard index == nil else {
      return
    }

    collectedItems.append(newitem)
  }

  func deleteItem(_ newitem: StoredItem) {
    guard let index = collectedItems.firstIndex(where: { item in
      item.id == newitem.id
    }) else {
      return
    }
    collectedItems.remove(at: index)
  }

  func addThings(_ newItems: [TransientItem], allItems: [TransientItem]) {
    allTransientItems = allItems
  }

  func updateThings(_ changedItems: [TransientItem], allItems: [TransientItem]) {
    allTransientItems = allItems
  }

  func removeThings(_ removedItems: [TransientItem], allItems: [TransientItem]) {
    allTransientItems = allItems
  }
}

extension DataStore {
  static let storageKey = "CollectedItems"

  func saveKeptItems() {
    let encoder = JSONEncoder()
    do {
      let data = try encoder.encode(collectedItems)
      UserDefaults.standard.set(data, forKey: DataStore.storageKey)
    } catch {
      print("save failure -\(error)")
    }
  }

  func restoreKeptItems() {
    do {
      guard let data = UserDefaults.standard.data(
        forKey: DataStore.storageKey
      ) else {
        return
      }

      let decoder = JSONDecoder()
      let items = try decoder.decode([StoredItem].self, from: data)
      collectedItems = items
    } catch {
      print("restore failure -\(error)")
    }
  }
}
