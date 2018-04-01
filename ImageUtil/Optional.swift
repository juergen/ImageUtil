public func >>-<A, B>(a: A?, f: (A) -> B?) -> B? {
  if let x = a {
    return f(x)
  } else {
    return .none
  }
}









