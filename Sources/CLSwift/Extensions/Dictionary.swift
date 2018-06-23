public extension Dictionary where Key == String, Value == StateType {
    public func difference(other: [Key: Value]) -> [Key: Value] {
        var differences = [Key: Value]()
        
        for (k, _) in self {
            if let changed = other[k]?.changed, changed {
                differences[k] = other[k]
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
    
    public func state<U, S>(for option: Option<U, S>) -> S? {
        return self[option.triggers.joined()] as? S
    }
}
