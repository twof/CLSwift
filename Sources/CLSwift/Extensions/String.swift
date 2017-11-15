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
}
