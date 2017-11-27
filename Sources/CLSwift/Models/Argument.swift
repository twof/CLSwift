import Foundation

public enum NumberOfArgs {
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

public protocol ProtoArg {
    var argStrings: [String] {get set}
    var type: LosslessStringConvertible.Type {get set}
    var state: State {get set}
    
    func execute(commandline: [ArgumentEntity])
}

public class Argument<U: LosslessStringConvertible>: ProtoArg {
    public var type: LosslessStringConvertible.Type = U.self
    public var argStrings: [String]
    public var state: State
    var associatedArguments: [ProtoFlag]
    var numArgs: NumberOfArgs
    var help: String
    
    var onExecution: ([U], State) -> ()
    
    public init(argStrings: [String],
                help: String,
                state: State=[:],
                numArgs: NumberOfArgs = .any,
                associatedArguments: [ProtoFlag]=[],
                onExecution: @escaping ([U], State) -> ()) {
        self.argStrings = argStrings
        self.help = help
        self.state = state
        self.numArgs = numArgs
        self.associatedArguments = associatedArguments

        self.onExecution = onExecution
    }
    
    public func execute(commandline: [ArgumentEntity]) {
        if !self.numArgs.isValid(args: commandline[0].parameters) {
//            return onExecution(.error(InputError.tooFewArgs))
            print(getHelp())
            return
        }
        
        for arg in associatedArguments {
            let argStrings = arg.argStrings
            
            for argString in argStrings {
                guard let foundIndex = commandline.index(where: { (token) -> Bool in
                    return token.command == argString
                }) else {continue}
                
                let triggeredFlag = commandline[foundIndex]
                
                do {
                    let changes = try arg.execute(entity: triggeredFlag, state: self.state).difference(other: self.state)
                    self.state = self.state.updated(with: changes)
                } catch {
                    print(getHelp())
                    return
//                    return onExecution(Result.error(error))
                }
            }
        }
        
        do {
            let args: [U] = try commandline[0].parameters.map { (arg) -> U in
                return try arg.convertTo(U.self)
            }
            
            return onExecution(args, self.state)
        } catch {
            print(getHelp())
            return
//            return onExecution(Result.error(error))
        }
    }
    
    private func getHelp() -> String {
        var usage =
"""
Usage: \(argStrings.joined(separator: "|")) \(numArgs.stringRep(typeString: String(describing: self.type))) [options]
        
"""
        var helpString =
"""
\(usage)
Description:
\(self.help)

"""
        
        for flag in associatedArguments {
            helpString.append("\n\(flag.getHelp())")
        }
        
        return helpString
    }
}
