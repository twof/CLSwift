/// ProtoFlags act as filters. Their only means of interaction with top tier arguments is through alteration
/// of arg.state
public protocol ProtoOption {
    var triggers: [String] {get set}
    var numParams: NumberOfParams {get set}
    var state: State {get set}
    func execute(entity: ArgumentEntity, state: State) throws -> State
    func getHelp() -> String
}

public class Option<U: LosslessStringConvertible>: ProtoOption {
    public var type: LosslessStringConvertible.Type = U.self
    public var triggers: [String]
    public var numParams: NumberOfParams
    public var state: State
    var help: String
    
    public var onExecution: ([U], State) -> State
    
    public init(triggers: [String],
                help: String,
                state: State,
                numParams: NumberOfParams = .any,
                onExecution: @escaping ([U], State) -> State) {
        self.triggers = triggers
        self.help = help
        self.state = state
        self.numParams = numParams
        
        self.onExecution = onExecution
    }
    
    public func execute(entity: ArgumentEntity, state: State) throws -> State {
        if !self.numParams.isValid(args: entity.parameters) {
            throw InputError.wrongNumberOfArgs(expected: self.numParams, actual: entity.parameters.count)
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
        let possibleArgs: String = self.triggers.joined(separator: ", ")
        let types: String = self.numParams.stringRep(typeString: String(describing: self.type))
        return "\(possibleArgs) \(types)    \(self.help)"
    }
}
