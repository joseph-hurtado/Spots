@testable import Spots
import Foundation
import XCTest
import Brick

class CompositionTests: XCTestCase {

  var component: Component!
  var spot: Spotable!

  override func tearDown() {
    component = nil
    spot = nil
  }

  func testComponentCreation() {
    component = Component(
      kind: Component.Kind.Grid.rawValue
    )

    component.add(child: Component(kind: Component.Kind.List.rawValue))

    XCTAssertEqual(component.items.count, 1)

    component.add(children: [
      Component(kind: Component.Kind.List.rawValue),
      Component(kind: Component.Kind.List.rawValue)
      ]
    )

    XCTAssertEqual(component.items.count, 3)
  }

  func testSpotableCreation() {
    component = Component(kind: Component.Kind.Grid.rawValue, span: 2.0)

    component.add(children: [
      Component(
        kind: Component.Kind.List.rawValue,
        items: [
          Item(title: "foo"),
          Item(title: "bar")
        ]
      ),
      Component(
        kind: Component.Kind.List.rawValue,
        items: [
          Item(title: "baz"),
          Item(title: "bal")
        ]
      )
      ]
    )

    spot = GridSpot(component: component)

    XCTAssertEqual(spot.items.count, 2)
    XCTAssertEqual(spot.compositeSpots.count, 2)
    XCTAssertEqual(spot.compositeSpots[0].spot.component.kind, Component.Kind.List.rawValue)
    XCTAssertEqual(spot.compositeSpots[0].spot.items.count, 2)
    XCTAssertEqual(spot.compositeSpots[0].spot.items[0].title, "foo")
    XCTAssertEqual(spot.compositeSpots[0].spot.items[1].title, "bar")
    
    XCTAssertEqual(spot.compositeSpots[1].spot.component.kind, Component.Kind.List.rawValue)
    XCTAssertEqual(spot.compositeSpots[1].spot.items.count, 2)
    XCTAssertEqual(spot.compositeSpots[1].spot.items[0].title, "baz")
    XCTAssertEqual(spot.compositeSpots[1].spot.items[1].title, "bal")
  }

  func testUICreation() {
    component = Component(kind: Component.Kind.Grid.rawValue, span: 2.0)

    component.add(children: [
      Component(
        kind: Component.Kind.List.rawValue,
        items: [
          Item(title: "foo"),
          Item(title: "bar")
        ]
      ),
      Component(
        kind: Component.Kind.List.rawValue,
        items: [
          Item(title: "baz"),
          Item(title: "bal")
        ]
      )
      ]
    )

    spot = GridSpot(component: component)
    spot.render().frame.size = CGSize(width: 200, height: 200)
    spot.render().layoutIfNeeded()

    var composite: Composable?
    var view: SpotConfigurable?
    
    composite = spot.ui(at: 0)
    view = spot.compositeSpots[0].spot.ui(at: 0)

    XCTAssertNotNil(composite)
    XCTAssertNotNil(view)
    XCTAssertEqual(composite?.contentView.subviews.count, 1)
    XCTAssertTrue(spot.compositeSpots[0].parentSpot!.component == spot.component)
    XCTAssertTrue(spot.compositeSpots[0].spot is Listable)
    XCTAssertEqual(spot.compositeSpots[0].spot.render().frame.size.height,
                   view!.preferredViewSize.height * CGFloat(spot.compositeSpots[0].spot.items.count))

    composite = spot.ui(at: 1)
    view = spot.compositeSpots[0].spot.ui(at: 1)

    XCTAssertNotNil(composite)
    XCTAssertEqual(composite?.contentView.subviews.count, 1)
    XCTAssertTrue(spot.compositeSpots[1].parentSpot!.component == spot.component)
    XCTAssertTrue(spot.compositeSpots[1].spot is Listable)
    XCTAssertEqual(spot.compositeSpots[1].spot.render().frame.size.height,
                   view!.preferredViewSize.height * CGFloat(spot.compositeSpots[1].spot.items.count))

    composite = spot.ui(at: 2)
    XCTAssertNil(composite)
  }

  func testReloadWithComponentsUsingComposition() {
    let initialComponents: [Component] = [
      Component(kind: Component.Kind.Grid.rawValue,
                span: 2.0,
                items: [
                  Item(kind: "composite", children:
                    [
                      Component(kind: Component.Kind.List.rawValue, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  ),
                  Item(kind: "composite", children:
                    [
                      Component(kind: Component.Kind.List.rawValue, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  )
        ]
      ),
      Component(kind: Component.Kind.Grid.rawValue,
                span: 2.0,
                items: [
                  Item(kind: "composite", children:
                    [
                      Component(kind: Component.Kind.List.rawValue, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  ),
                  Item(kind: "composite", children:
                    [
                      Component(kind: Component.Kind.List.rawValue, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  )
        ]
      )
    ]

    let controller = Controller(spots: Parser.parse(components: initialComponents))
    controller.view.layoutIfNeeded()
    let spots = controller.spots

    XCTAssertEqual(spots.count, 2)

    var composite: Composable?
    var spotConfigurable: SpotConfigurable?

    composite = spots[0].ui(at: 0)
    spotConfigurable = spots[0].compositeSpots[0].spot.ui(at: 0)

    XCTAssertNotNil(composite)
    XCTAssertNotNil(spotConfigurable)
    XCTAssertEqual(composite?.contentView.subviews.count, 1)
    XCTAssertTrue(spots[0].compositeSpots[0].parentSpot!.component == spots[0].component)
    XCTAssertTrue(spots[0].compositeSpots[0].spot is Listable)
    XCTAssertEqual(spots[0].compositeSpots[0].spot.items.count, 10)
    XCTAssertEqual(spots[0].compositeSpots[0].spot.render().frame.size.height,
                   spotConfigurable!.preferredViewSize.height * CGFloat(spots[0].compositeSpots[0].spot.items.count))

    spotConfigurable = spots[0].compositeSpots[1].spot.ui(at: 0)

    XCTAssertNotNil(spotConfigurable)
    XCTAssertEqual(composite?.contentView.subviews.count, 1)
    XCTAssertTrue(spots[0].compositeSpots[1].parentSpot!.component == spots[0].component)
    XCTAssertTrue(spots[0].compositeSpots[1].spot is Listable)
    XCTAssertEqual(spots[0].compositeSpots[1].spot.items.count, 10)
    XCTAssertEqual(spots[0].compositeSpots[1].spot.render().frame.size.height,
                   spotConfigurable!.preferredViewSize.height * CGFloat(spots[0].compositeSpots[1].spot.items.count))

    XCTAssertNotNil(composite)
    XCTAssertNotNil(spotConfigurable)
    XCTAssertEqual(composite?.contentView.subviews.count, 1)
    XCTAssertTrue(spots[1].compositeSpots[0].parentSpot!.component == spots[0].component)
    XCTAssertTrue(spots[1].compositeSpots[0].spot is Listable)
    XCTAssertEqual(spots[1].compositeSpots[0].spot.items.count, 10)
    XCTAssertEqual(spots[1].compositeSpots[0].spot.render().frame.size.height,
                   spotConfigurable!.preferredViewSize.height * CGFloat(spots[1].compositeSpots[0].spot.items.count))

    spotConfigurable = spots[0].compositeSpots[1].spot.ui(at: 0)

    XCTAssertNotNil(spotConfigurable)
    XCTAssertEqual(composite?.contentView.subviews.count, 1)
    XCTAssertTrue(spots[1].compositeSpots[1].parentSpot!.component == spots[0].component)
    XCTAssertTrue(spots[1].compositeSpots[1].spot is Listable)
    XCTAssertEqual(spots[1].compositeSpots[1].spot.items.count, 10)
    XCTAssertEqual(spots[1].compositeSpots[1].spot.render().frame.size.height,
                   spotConfigurable!.preferredViewSize.height * CGFloat(spots[1].compositeSpots[1].spot.items.count))

    let newComponents: [Component] = [
      Component(kind: Component.Kind.Grid.rawValue,
                span: 1.0,
                items: [
                  Item(kind: "composite", children:
                    [
                      Component(kind: Component.Kind.List.rawValue, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  ),
                  Item(kind: "composite", children:
                    [
                      Component(kind: Component.Kind.List.rawValue, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  )
        ]
      ),
      Component(kind: Component.Kind.Grid.rawValue,
                span: 3.0,
                items: [
                  Item(kind: "composite", children:
                    [
                      Component(kind: Component.Kind.List.rawValue, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  ),
                  Item(kind: "composite", children:
                    [
                      Component(kind: Component.Kind.List.rawValue, items: [
                        Item(title: "Item 1"),
                        Item(title: "Item 2"),
                        Item(title: "Item 3"),
                        Item(title: "Item 4"),
                        Item(title: "Item 5"),
                        Item(title: "Item 6"),
                        Item(title: "Item 7"),
                        Item(title: "Item 8"),
                        Item(title: "Item 9"),
                        Item(title: "Item 10")
                        ]
                      )
                    ]
                  )
        ]
      )
    ]

    let exception = self.expectation(description: "Reload controller with components")
    controller.reloadIfNeeded(newComponents) {
      exception.fulfill()
    }
    waitForExpectations(timeout: 1.0, handler: nil)
  }
}
