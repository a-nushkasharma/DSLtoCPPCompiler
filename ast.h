
#pragma once
#include <memory>
#include <string>
#include <vector>
#include <iostream>

struct Expression {
    virtual ~Expression() = default;
    virtual void generate(std::ostream& out) const = 0;
};

struct NumberExpr : public Expression {
    int value;
    NumberExpr(int val) : value(val) {}
    void generate(std::ostream& out) const override {
        out << value;
    }
};

struct VariableExpr :public Expression {
    std::string name;
    VariableExpr(const std::string& n) : name(n) {}
    void generate(std::ostream& out) const override {
        out << name;
    }
};

struct BinaryExpr : public Expression {
    std::string op;
    std::unique_ptr<Expression> lhs, rhs;
    BinaryExpr(std::string o, std::unique_ptr<Expression> l, std::unique_ptr<Expression> r)
        : op(std::move(o)), lhs(std::move(l)), rhs(std::move(r)) {}
    void generate(std::ostream& out) const override {
        out << "(";
        lhs->generate(out);
        out << " " << op << " ";
        rhs->generate(out);
        out << ")";
    }
};

struct VarDecl {
    std::string name;
    std::unique_ptr<Expression> expr;

    VarDecl(std::string n, std::unique_ptr<Expression> e)
        : name(std::move(n)), expr(std::move(e)) {}

    // Enable move semantics
    VarDecl(VarDecl&&) = default;
    VarDecl& operator=(VarDecl&&) = default;

    // Disable copy semantics
    VarDecl(const VarDecl&) = delete;
    VarDecl& operator=(const VarDecl&) = delete;

    void generate(std::ostream& out) const {
        out << "    unsigned int " << name << " = ";
        expr->generate(out);
        out << ";\n";
    }
};

struct Contract {
    std::string name;
    std::vector<VarDecl> variables;

    void generate(std::ostream& out) const {
    out << "#include <iostream>\n";
     out << "class " << name << " {\n";
    out << "public:\n";

    for (const auto& var : variables) {
        var.generate(out);  // call VarDecl::generate
    }

    out << "};\n\n";
     out << "int main() {\n";
    out << "    " << name << " obj;\n";
    out << "    std::cout << \"result: \" << obj." << variables.back().name << " << std::endl;\n";
    out << "    return 0;\n";
    out << "}\n";
}
};
//Code for complete semantics 
/*
#ifndef AST_H
#define AST_H

#include <iostream>
#include <memory>
#include <string>
#include <vector>

enum class Type { UINT, INT, BOOL, ADDRESS };

struct Expression {
    virtual ~Expression() = default;
    virtual void generate(std::ostream& os) const = 0;
};

struct NumberExpr : public Expression {
    int value;
    NumberExpr(int val) : value(val) {}
    void generate(std::ostream& os) const override { os << value; }
};

struct BoolExpr : public Expression {
    bool value;
    BoolExpr(bool val) : value(val) {}
    void generate(std::ostream& os) const override { os << (value ? "true" : "false"); }
};

struct AddressExpr : public Expression {
    std::string value;
    AddressExpr(const std::string& val) : value(val) {}
    void generate(std::ostream& os) const override { os << "\"" << value << "\""; }
};

struct VariableExpr : public Expression {
    std::string name;
    VariableExpr(const std::string& n) : name(n) {}
    void generate(std::ostream& os) const override { os << name; }
};

struct UnaryExpr : public Expression {
    std::string op;
    std::unique_ptr<Expression> expr;
    UnaryExpr(const std::string& o, std::unique_ptr<Expression> e) : op(o), expr(std::move(e)) {}
    void generate(std::ostream& os) const override {
        os << op; expr->generate(os);
    }
};

struct BinaryExpr : public Expression {
    std::string op;
    std::unique_ptr<Expression> lhs, rhs;
    BinaryExpr(const std::string& o, std::unique_ptr<Expression> l, std::unique_ptr<Expression> r)
        : op(o), lhs(std::move(l)), rhs(std::move(r)) {}
    void generate(std::ostream& os) const override {
        os << "("; lhs->generate(os); os << " " << op << " "; rhs->generate(os); os << ")";
    }
};

struct VarDecl {
    Type type;
    std::string name;
    std::unique_ptr<Expression> init;
    void generate(std::ostream& os) const {
        std::string typeStr = (type == Type::UINT ? "unsigned int" :
                              type == Type::INT ? "int" :
                              type == Type::BOOL ? "bool" : "std::string");
        os << typeStr << " " << name;
        if (init) {
            os << " = ";
            init->generate(os);
        }
        os << ";" << std::endl;
    }
};

struct Statement {
    virtual ~Statement() = default;
    virtual void generate(std::ostream& os) const = 0;
};

struct ExprStmt : public Statement {
    std::unique_ptr<Expression> expr;
    ExprStmt(std::unique_ptr<Expression> e) : expr(std::move(e)) {}
    void generate(std::ostream& os) const override {
        expr->generate(os); os << ";" << std::endl;
    }
};

struct ReturnStmt : public Statement {
    std::unique_ptr<Expression> expr;
    ReturnStmt(std::unique_ptr<Expression> e) : expr(std::move(e)) {}
    void generate(std::ostream& os) const override {
        os << "return "; expr->generate(os); os << ";" << std::endl;
    }
};

struct Function {
    std::string name;
    Type returnType;
    std::vector<VarDecl> params;
    std::vector<std::unique_ptr<Statement>> body;

    void generate(std::ostream& os) const {
        std::string ret = (returnType == Type::UINT ? "unsigned int" :
                          returnType == Type::INT ? "int" :
                          returnType == Type::BOOL ? "bool" : "std::string");

        os << ret << " " << name << "(";
        for (size_t i = 0; i < params.size(); ++i) {
            const auto& p = params[i];
            std::string typeStr = (p.type == Type::UINT ? "unsigned int" :
                                  p.type == Type::INT ? "int" :
                                  p.type == Type::BOOL ? "bool" : "std::string");
            os << typeStr << " " << p.name;
            if (i < params.size() - 1) os << ", ";
        }
        os << ") {" << std::endl;
        for (auto& stmt : body) stmt->generate(os);
        os << "}" << std::endl;
    }
};

struct Contract {
    std::string name;
    std::vector<Function> functions;

    void generate(std::ostream& os) const {
        os << "#include <iostream>" << std::endl;
        os << "#include <string>" << std::endl;
        os << "class " << name << " {" << std::endl;
        os << "public:" << std::endl;
        for (const auto& func : functions) func.generate(os);
        os << "};" << std::endl;
    }
};

#endif
*/
