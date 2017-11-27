/// ProtoFlags act as filters. Their only means of interaction with top tier arguments is through alteration
/// of arg.state
public protocol ProtoFlag {
    var argStrings: [String] {get set}
    var numArgs: NumberOfArgs {get set}
    func execute(entity: ArgumentEntity, state: State) throws -> State
    func getHelp() -> String
}

public class Flag<U: LosslessStringConvertible>: ProtoFlag {
    public var type: LosslessStringConvertible.Type = U.self
    public var argStrings: [String]
    public var numArgs: NumberOfArgs
    var help: String
    
    public var onExecution: ([U], State) -> State
    
    public init(argStrings: [String],
                help: String,
                numArgs: NumberOfArgs = .any,
                onExecution: @escaping ([U], State) -> State) {
        self.argStrings = argStrings
        self.help = help
        self.numArgs = numArgs
        
        self.onExecution = onExecution
    }
    
    public func execute(entity: ArgumentEntity, state: State) throws -> State {
        if !self.numArgs.isValid(args: entity.parameters) {
            throw InputError.wrongNumberOfArgs(expected: self.numArgs, actual: entity.parameters.count)
        }
        
        do {
            let args: [U] = try entity.parameters.map { (arg) -> U in
                return try arg.convertTo(U.self)
            }
            
            return onExecution(args, state)
        } catch {
            throw error
        }
    }
    
    public func getHelp() -> String {
        let possibleArgs: String = self.argStrings.joined(separator: ", ")
        let types: String = self.numArgs.stringRep(typeString: String(describing: self.type))
        return "\(possibleArgs) \(types)    \(self.help)"
    }
}
