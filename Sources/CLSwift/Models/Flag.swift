/// ProtoFlags act as filters. Their only means of interaction with top tier arguments is through alteration
/// of arg.state
public protocol ProtoFlag {
    var argStrings: [String] {get set}
    var numArgs: NumberOfArgs {get set}
    func execute(entity: ArgumentEntity, state: [String: Any]) throws -> [String: Any]
}

class Flag<U: LosslessStringConvertible>: ProtoFlag {
    var argStrings: [String]
    var numArgs: NumberOfArgs
    
    var onExecution: ([U], State) -> State
    
    public init(argStrings: [String], numArgs: NumberOfArgs = .none, onExecution: @escaping ([U], State) -> [String: Any]) {
        self.argStrings = argStrings
        self.numArgs = numArgs
        
        self.onExecution = onExecution
    }
    
    func execute(entity: ArgumentEntity, state: State) throws -> [String : Any] {
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
