/// ProtoFlags act as filters. Their only means of interaction with top tier arguments is through alteration
/// of arg.state
public protocol ProtoFlag {
    var argStrings: [String] {get set}
    var numArgs: NumberOfArgs {get set}
    func execute(entity: ArgumentEntity, state: State) throws -> State
}

public class Flag<U: LosslessStringConvertible>: ProtoFlag {
    public var argStrings: [String]
    public var numArgs: NumberOfArgs
    
    public var onExecution: ([U], State) -> State
    
    public init(argStrings: [String], numArgs: NumberOfArgs = .none, onExecution: @escaping ([U], State) -> State) {
        self.argStrings = argStrings
        self.numArgs = numArgs
        
        self.onExecution = onExecution
    }
    
    public func execute(entity: ArgumentEntity, state: State) throws -> State {
        if !self.numArgs.isValid(args: entity.parameters) {
            throw InputError.tooFewArgs
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
}
