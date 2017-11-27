public extension Dictionary where Key: Comparable, Value: Equatable {
    public func difference(other: [Key: Value]) -> [Key: Value] {
        var differences = [Key: Value]()
        for (k, v) in self {
            if other[k] != v {
                differences[k] = v
            }
        }
        
        return differences
    }
    
    public func updated(with changes: [Key: Value]) -> [Key: Value] {
        var newDict = self
        for (k, v) in changes {
            newDict[k] = v
        }
        
        return newDict
    }
}
