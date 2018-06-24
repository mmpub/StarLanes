// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "starlanes",
    products: [ .executable(name: "starlanes", targets: ["starlanes"])],
    targets: [.target(name: "starlanes", dependencies: [], path: "Sources")]
)
