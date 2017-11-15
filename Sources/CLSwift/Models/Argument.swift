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
        
        // subtracting one for the path and one for the top level arg
        if !self.numArgs.isValid(args: commandline[0].parameters) {
            return onExecution(.error(InputError.tooFewArgs))
        }
        
        let args: [U?] = commandline[0].parameters.map { (arg) -> U? in
            if let casted = convert(value: arg, type: U.self) {
                return casted
            }else{
                return nil
            }
        }
        
        if args.contains(where: { (item) -> Bool in
            return item == nil
        }) {
            return onExecution(Result.error(InputError.invalidType("Could not cast one of the parameters to the specified type: \(U.self)")))
        }else{
            return onExecution(Result.success((args as! [U])))
        }
    }
    
    private func convert<T: LosslessStringConvertible>(value: String, type: T.Type) -> T? {
        return T.self.init(value)
    }
}
