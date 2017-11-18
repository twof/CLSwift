import Foundation

public extension String {
    /// Returns true if a string has any one of a list of prefixes
    /// Can be treated like a boolean OR
    func hasPrefix(prefix: [String]) -> Bool{
        for pre in prefix {
            if self.contains(pre) {
                return true
            }
        }
        return false
    }
    
    /// Convert self to any type that conforms to LosslessStringConvertible
    func convertTo<T: LosslessStringConvertible>(_ type: T.Type) throws -> T {
        guard let converted = T.self.init(self) else {
            throw InputError.invalidType("Unable to convert \(self) is not a \(T.Type.self)")
        }
        
        return converted
    }
}
