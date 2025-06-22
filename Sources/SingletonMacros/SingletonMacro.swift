import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Macro for generating static 'let shared' property.
/// It produces only one instance of a class or a struct.
public struct SingletonMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let ownerName: TokenSyntax

        if let owner = declaration.as(ClassDeclSyntax.self) {
            ownerName = owner.name
        } else if let owner = declaration.as(StructDeclSyntax.self) {
            ownerName = owner.name
        } else {
            fatalError("The @Singleton macro can only be applied to 'class' and 'struct' declarations")
        }

        let variable = try VariableDeclSyntax("static let shared = \(ownerName.trimmed)()")
        let initializer = try InitializerDeclSyntax("private init()") { }
        return [DeclSyntax(variable), DeclSyntax(initializer)]
    }
}

@main
struct SingletonPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        SingletonMacro.self,
    ]
}
