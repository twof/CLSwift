/// ProtoFlags act as filters. Their only means of interaction with top tier arguments is through alteration
/// of arg.state
public protocol ProtoOption {
    var triggers: [String] {get set}
    var numParams: NumberOfParams {get set}
    var state: StateType {get set}
    func execute(entity: ArgumentEntity, state: [String: StateType]) throws -> [String: StateType]
    func getHelp() -> String
}

public class Option<U: LosslessStringConvertible, S: StateType>: ProtoOption {
    public var type: LosslessStringConvertible.Type = U.self
    public var triggers: [String]
    public var numParams: NumberOfParams
    public var state: StateType
    var help: String
    
    public var onExecution: ([U], S) -> S
    
    public init(
        triggers: [String],
        help: String,
        state: S,
        numParams: NumberOfParams = .any,
        onExecution: @escaping ([U], S) -> S
    ) {
        self.triggers = triggers
        self.help = help
        self.state = state
        self.numParams = numParams
        
        self.onExecution = onExecution
    }
    
    public func execute(entity: ArgumentEntity, state: [String: StateType]) throws -> [String: StateType] {
        
        if !self.numParams.isValid(args: entity.parameters) {
            throw InputError.wrongNumberOfArgs(expected: self.numParams, actual: entity.parameters.count)
        }
        
        do {
            let args: [U] = try entity.parameters.map { (arg) -> U in
                return try arg.convertTo(U.self)
            }
            
            guard let typedState: StateType = state[self.triggers.joined()] else { assertionFailure(); return [:] }
            
            var newState: [String: StateType] = state
            let change = self.onExecution(args, typedState as! S)
            change.changed = true
            newState[self.triggers.joined()] = change
            
            return newState
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

extension Option: Hashable {
    public var hashValue: Int {
        return triggers.joined().hashValue
    }
    
    public static func == (lhs: Option<U, S>, rhs: Option<U, S>) -> Bool {
        return lhs.triggers == rhs.triggers
    }
}
