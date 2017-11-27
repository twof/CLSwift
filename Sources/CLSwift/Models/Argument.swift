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
}

public protocol ProtoArg {
    var argStrings: [String] {get set}
    var type: LosslessStringConvertible.Type {get set}
    var state: [String: Any] {get set}
    
    func execute(commandline: [ArgumentEntity])
}

public class Argument<U: LosslessStringConvertible>: ProtoArg {
    public var type: LosslessStringConvertible.Type = U.self
    public var argStrings: [String]
    public var state: [String: Any]
    var associatedArguments: [ProtoFlag]?
    var numArgs: NumberOfArgs
    
    var onExecution: (Result<[U]>) -> ()
    
    public init(argStrings: [String], state: [String: Any]=[:], numArgs: NumberOfArgs = .any, associatedArguments: [ProtoFlag]?=nil, onExecution: @escaping (Result<[U]>) -> ()) {
        self.argStrings = argStrings
        self.state = state
        self.numArgs = numArgs
        self.associatedArguments = associatedArguments
        
        self.onExecution = onExecution
    }
    
    public func execute(commandline: [ArgumentEntity]) {
        if !self.numArgs.isValid(args: commandline[0].parameters) {
            return onExecution(.error(InputError.tooFewArgs))
        }
        
        if let associatedArguments = self.associatedArguments {
            for arg in associatedArguments {
                let argStrings = arg.argStrings
                
                for argString in argStrings {
                    guard let foundIndex = commandline.index(where: { (token) -> Bool in
                        return token.command == argString
                    }) else {continue}
                    
                    let triggeredFlag = commandline[foundIndex]
                    
                    do {
                        self.state = try arg.execute(entity: triggeredFlag, state: self.state)
                    } catch {
                        return onExecution(Result.error(error))
                    }
                }
            }
        }
        
        do {
            let args: [U] = try commandline[0].parameters.map { (arg) -> U in
                return try arg.convertTo(U.self)
            }
            
            return onExecution(Result.success(args, self.state))
        } catch {
            return onExecution(Result.error(error))
        }
    }
}
