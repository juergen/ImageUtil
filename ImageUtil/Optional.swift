public func >>-<A, B>(a: A?, f: A -> B?) -> B? {
  if let x = a {
    return f(x)
  } else {
    return .None
  }
}

public func <^><A, B>(f: A -> B, a: A?) -> B? {
  if let x = a {
    return f(x)
  } else {
    return .None
  }
}

public func <*><A, B>(f: (A -> B)?, a: A?) -> B? {
  if let x = a {
    if let fx = f {
      return fx(x)
    }
  }
  return .None
}

public func <|<K,V>(d: Dictionary<K,V>?, key: K) -> V? {
    if let dx = d{
        return dx[key]
    }
    return .None
}

public func <|><K,V>(d: Dictionary<K,V>?, key: K) -> Dictionary<K,V>? {
    if let dx = d{
        return dx[key] as? Dictionary
    }
    return .None
}


