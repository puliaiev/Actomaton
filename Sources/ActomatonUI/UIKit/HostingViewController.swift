#if os(iOS) || os(tvOS)

import UIKit
import Combine
import SwiftUI

/// SwiftUI `View` & ``Store`` wrapper view controller that holds `UIHostingController`.
@MainActor
open class HostingViewController<Action, State, Environment, V: SwiftUI.View>: UIViewController
    where Action: Sendable, State: Sendable, Environment: Sendable
{
    private let store: Any // `Store` or `RouteStore`.
    private let rootView: AnyView

    /// Initializer for ``Store`` as argument.
    public init(
        store: Store<Action, State, Environment>,
        makeView: @escaping @MainActor (Store<Action, State, Environment>) -> V
    )
    {
        self.store = store
        self.rootView = AnyView(makeView(store))
        super.init(nibName: nil, bundle: nil)
    }

    /// Initializer for ``RouteStore`` as argument, with forgetting ``SendRouteEnvironment/sendRoute`` capability when `makeView`.
    public init<Route>(
        store routeStore: RouteStore<Action, State, Environment, Route>,
        makeView: @escaping @MainActor (Store<Action, State, Environment>) -> V
    )
    {
        self.store = routeStore

        let substore = routeStore.noSendRoute
        self.rootView = AnyView(makeView(substore))

        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

    open override func viewDidLoad()
    {
        super.viewDidLoad()

        let hostVC = UIHostingController(rootView: rootView)
        hostVC.view.translatesAutoresizingMaskIntoConstraints = false

        self.addChild(hostVC)
        self.view.addSubview(hostVC.view)
        hostVC.didMove(toParent: self)

        NSLayoutConstraint.activate([
            self.view.leadingAnchor.constraint(equalTo: hostVC.view.leadingAnchor),
            self.view.trailingAnchor.constraint(equalTo: hostVC.view.trailingAnchor),
            self.view.topAnchor.constraint(equalTo: hostVC.view.topAnchor),
            self.view.bottomAnchor.constraint(equalTo: hostVC.view.bottomAnchor)
        ])
    }
}

#endif
