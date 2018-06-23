import Foundation

public enum NumberOfParams {
    case none
    case range(Range<Int>)
    case greaterThan(Int)
    case lessThan(Int)
    case number(Int)
    case any
    
    func isValid(args: [String]) -> Bool {
        switch self {
        case .none:
            return args.count == 0
        case .range(let range):
            return range.contains(args.count)
        case .greaterThan(let num):
            return args.count > num
        case .lessThan(let num):
            return args.count < num
        case .number(let num):
            return args.count == num
        case .any:
            return true
        }
    }
    
    func stringRep(typeString: String) -> String {
        switch self {
        case .none:
            return ""
        case .range(let range):
            return "<\(String(describing: range)) of \(typeString)>"
        case .greaterThan(let num):
            return "< >\(num) of \(typeString)>"
        case .lessThan(let num):
            return "< <\(num) of \(typeString)>"
        case .number(let num):
            let types = Array(repeating: typeString, count: num).joined(separator: ", ")
            return "<\(types)>"
        case .any:
            return ""
        }
    }
}

public protocol ProtoCommand {
    var triggers: [String] {get set}
    var type: LosslessStringConvertible.Type {get set}
    var state: [String: StateType] {get set}
    
    func execute(commandline: [ArgumentEntity])
}

public class Command<U: LosslessStringConvertible>: ProtoCommand {
    public var type: LosslessStringConvertible.Type = U.self
    public var triggers: [String]
    public var state: [String: StateType] = [:]
    var options: [ProtoOption]
    var numParams: NumberOfParams
    var help: String
    
    var onExecution: ([U], [String: StateType]) throws -> ()
    
    public init(
        triggers: [String],
        help: String,
        numParams: NumberOfParams = .any,
        options: [ProtoOption]=[],
        onExecution: @escaping ([U], [String: StateType]) throws -> ()
    ) {
        self.triggers = triggers
        self.help = help
        self.numParams = numParams
        self.options = options

        self.onExecution = onExecution
        
        self.state = options.reduce(into: [String: StateType]()) { (result, option) in
            result[option.triggers.joined() as String] = option.state
        }
    }
    
    public func execute(commandline: [ArgumentEntity]) {
        if !self.numParams.isValid(args: commandline[0].parameters) {
            print(getHelp())
            return
        }
        
        for arg in options {
            let argStrings = arg.triggers
            
            for argString in argStrings {
                guard let foundIndex = commandline.index(where: { (token) -> Bool in
                    return token.command == argString
                }) else {continue}
                
                let triggeredFlag = commandline[foundIndex]
                
                do {
                    let changes = try arg.execute(entity: triggeredFlag, state: self.state)
                    let differences = self.state.difference(other: changes)
                    self.state = self.state.updated(with: differences)
                } catch {
                    print(getHelp())
                    return
                }
            }
        }
        
        do {
            let args: [U] = try commandline[0].parameters.map { (arg) -> U in
                return try arg.convertTo(U.self)
            }
            
            return try onExecution(args, self.state)
        } catch InputError.customError(let message) {
            print(message)
            return
        } catch {
            print(getHelp())
            return
        }
    }
    
    private func getHelp() -> String {
        let usage =
"""
Usage: \(triggers.joined(separator: "|")) \(numParams.stringRep(typeString: String(describing: self.type))) [options]
        
"""
        var helpString =
"""
\(usage)
Description:
\(self.help)

"""
        
        for flag in options {
            helpString.append("\n\(flag.getHelp())")
        }
        
        return helpString
    }
}
