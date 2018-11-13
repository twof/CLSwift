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

public struct Executable<Construct, ParamType: LosslessStringConvertible> {
    var onExecution: ([ParamType], State) throws -> ()
    var execute: ([ArgumentEntity]) -> ()
}

public struct CommandWitnessFactory<ParamType: LosslessStringConvertible> {
    public static func mainWitness(
        command: Command,
        onExecution: @escaping ([ParamType], State) throws -> ()
    ) -> Executable<Command, ParamType> {
        func getHelp() -> String {
            let usage =
            """
            Usage: \(command.triggers.joined(separator: "|")) \(command.numParams.stringRep(typeString: String(describing: ParamType.self))) [options]
            
            """
            var helpString =
            """
            \(usage)
            Description:
            \(command.help)
            
            """
            
            //        for flag in options {
            //            helpString.append("\n\(flag.getHelp())")
            //        }
            
            return helpString
        }
        
        return Executable<Command, ParamType>(onExecution: onExecution, execute: { (commandline) in
            if !command.numParams.isValid(args: commandline[0].parameters) {
                print(getHelp())
                return
            }
            
            //        for arg in options {
            //            let argStrings = arg.triggers
            //
            //            for argString in argStrings {
            //                guard let foundIndex = commandline.index(where: { (token) -> Bool in
            //                    return token.command == argString
            //                }) else {continue}
            //
            //                let triggeredFlag = commandline[foundIndex]
            //
            //                do {
            //                    let changes = try arg.execute(entity: triggeredFlag, state: self.state).difference(other: self.state)
            //                    self.state = self.state.updated(with: changes)
            //                } catch {
            //                    print(getHelp())
            //                    return
            //                }
            //            }
            //        }
            
            do {
                let args: [ParamType] = try convert(from: commandline[0], to: ParamType.self)
                
                return try onExecution(args, command.state)
            } catch InputError.customError(let message) {
                print(message)
                return
            } catch {
                print(getHelp())
                return
            }
        })
    }
}



//public protocol ProtoCommand {
//    var triggers: [String] {get set}
//    var type: LosslessStringConvertible.Type {get set}
//    var state: State {get set}
//    
//    func execute(commandline: [ArgumentEntity])
//}

func convert<T: LosslessStringConvertible>(from argument: ArgumentEntity, to targetType: T.Type) throws -> [T] {
    return try argument.parameters.map { (param) -> T in
        return try param.convertTo(T.self)
    }
}

public class Command {
    public var triggers: [String]
    public var state: State = [:]
//    var options: [ProtoOption]
    var numParams: NumberOfParams
    var help: String
    
    public init(
        triggers: [String],
        help: String,
        numParams: NumberOfParams = .any,
        options: [ProtoOption]=[]
    ) {
        self.triggers = triggers
        self.help = help
        self.numParams = numParams
//        self.options = options
        
        self.state = options.reduce(into: [:]) { (result, option) in
            option.state.forEach { result[$0] = $1 }
        }
    }
}
