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
    
    func execute(commandline: [ArgumentEntity])
}

public class Argument<U: LosslessStringConvertible>: ProtoArg {
    public var type: LosslessStringConvertible.Type = U.self
    public var argStrings: [String]
    var associatedArguments: [Argument]?
    var required: Bool
    var location: Int?
    var numArgs: NumberOfArgs
    
    var onExecution: (Result<[U]>) -> ()
    
    public init(argStrings: [String], numArgs: NumberOfArgs = .none, required: Bool=false, associatedArguments: [Argument]?=nil, onExecution: @escaping (Result<[U]>) -> ()) {
        self.argStrings = argStrings
        self.required = required
        self.numArgs = numArgs
        self.associatedArguments = associatedArguments
        
        self.onExecution = onExecution
    }
    
    func existsAt(params: [String]) -> Int? {
        for argString in argStrings {
            if let location = params.index(of: argString) {
                return location
            }
        }
        
        return nil
    }
    
    public func execute(commandline: [ArgumentEntity]) {
        if !self.numArgs.isValid(args: commandline[0].parameters) {
            return onExecution(.error(InputError.tooFewArgs))
        }
        
        do {
            let args: [U] = try commandline[0].parameters.map { (arg) -> U in
                return try arg.convertTo(U.self)
            }
            
            return onExecution(Result.success(args))
        } catch {
            return onExecution(Result.error(error))
        }
    }
}
