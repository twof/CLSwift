import Foundation

/// Takes CommandLine.arguments and groups commands/flags with their options
public extension Array where Element == String {
    func group(by isNew:  (String) -> Bool) -> [(command: String, arguments: [String])]{
        guard self.count > 0 else { return [] }
        var grouped = [(String, [String])]()
        var currentCommand = self[0]
        var currentArgs = [String]()
        
        for i in 1..<self.count {
            if isNew(self[i]) {
                grouped.append((currentCommand, currentArgs))
                currentCommand = self[i]
                currentArgs = []
            } else {
                currentArgs.append(self[i])
            }
        }
        
        grouped.append((currentCommand, currentArgs))
        
        return grouped
    }
}
