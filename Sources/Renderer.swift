@_exported import StructuredData

public typealias Context = StructuredData

extension Context {
    var stringyValue: String? {
        switch self {

        case let .string(value): return value
        case let .int(value): return String(value)
        case let .double(value): return String(value)

        case let .array(values):
            var out = ""
            for value in values {
                guard let string = value.stringyValue else {
                    return nil
                }
                out += string
            }
            return out

        default: return nil
        }
    }
    var truthyValue: Bool {
        switch self {
        case let .bool(bool):
            return bool
        case let .array(array):
            return !array.isEmpty
        case let .dictionary(dictionary):
            return !dictionary.isEmpty
        default:
            return true
        }
    }
}

extension Sequence where Iterator.Element == Context {
    func value(of variable: String) -> Context? {
        let components = variable.characters.split(separator: ".").map({ String($0) })

        switch components.count {
        case 1:
            if variable == "." {
                return self.first(where: { _ in true })
            }
            for context in self {
                if
                    case let .dictionary(dictionary) = context,
                    let value = dictionary[variable] {
                    return value
                }
            }
            return nil

        default:
            var stack = Array(self)
            for component in components {
                guard let value = stack.value(of: component) else {
                    return nil
                }
                stack = [value]
            }
            return stack.first
        }
    }
}

func render(ast: AST, context: Context) -> String {
    return render(ast: ast, contextStack: [context])
}

func render(ast: AST, contextStack: [Context]) -> String {
    var out = ""

    for node in ast {
        switch node {

        case let .text(text):
            out += text

        case let .variable(variable, escaped):
            if let variable = contextStack.value(of: variable)?.stringyValue {
                switch escaped {
                case true: out += escapeHTML(variable)
                case false: out += variable
                }
            }

        case let .section(variable, inverted, innerAST):
            let truthyContext: Context? = {
                guard let context = contextStack.value(of: variable), context.truthyValue else {
                    return nil
                }
                return context
            }()

            switch inverted {
            case true:
                if truthyContext == nil {
                    out += render(ast: innerAST, contextStack: contextStack)
                }
            case false:
                guard let context = truthyContext else {
                    break
                }
                if case let .array(innerContexts) = context {
                    out += innerContexts.map { render(ast: innerAST, contextStack: [$0] + contextStack) }.joined(separator: "")
                } else {
                    out += render(ast: innerAST, contextStack: [context] + contextStack)
                }
            }

        case let .partial(partial):
            out += render(ast: partial, contextStack: contextStack)
        }
    }

    return out
}
