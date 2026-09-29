#!/usr/bin/env python3
"""r11u233: mkcases_j.py: writes cases/J: the break shapes of § memberInitReducedRootFolds228 found on cases/M (a root
whose value READS a struct parameter or holds a cast below a concatenation or a pattern member, a unary member),
written in v11u228 FM f03's form (the typedef inside the module), where the pristine database is judge-equal."""
import os
R = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'cases', 'J')
L = '// § memberInitReducedRootFolds228 § memberRootFoldShapes228v — '
def one(name, desc, root, pre=''):
    p = os.path.join(R, name); os.makedirs(p, exist_ok=True)
    open(os.path.join(p, 'dut.sv'), 'w').write(L + desc + '\n' + f'''module top #(parameter bit SEL = 1) (output int o);
   typedef struct packed {{ int x; }} info_t;
{pre}   parameter info_t Info = {root};
   localparam int N = Info.x;
   logic [N-1:0] data;
   assign data = '1;
   assign o = int'(data);
endmodule
''')
one('j01', 'an arithmetic of a cast struct parameter (B + 0)', 'B + 0', "   parameter info_t B = info_t'(16);\n")
one('j02', 'an arithmetic of an untyped-pattern struct parameter (B + 0)', 'B + 0', "   parameter info_t B = '{x: 16};\n")
one('j03', "an untyped pattern reading a cast struct parameter's member ('{x: B.x})", "'{x: B.x}", "   parameter info_t B = info_t'(16);\n")
one('j04', "an untyped pattern reading an untyped struct parameter's member ('{x: B.x})", "'{x: B.x}", "   parameter info_t B = '{x: 16};\n")
one('j05', 'a parenthesized concatenation holding a cast (({info_t\'(16)}))', "({info_t'(16)})")
one('j06', 'a concatenation holding a cast ({info_t\'(16)})', "{info_t'(16)}")
one('j07', 'an untyped pattern with a unary member (\'{x: +16})', "'{x: +16}")
one('j08', 'a bitwise or of a cast struct parameter (B | 0)', 'B | 0', "   parameter info_t B = info_t'(16);\n")
one('j09', 'a concatenation of a struct parameter ({B})', '{B}', "   parameter info_t B = info_t'(16);\n")
one('j10', "an untyped pattern whose member is an arithmetic of a struct parameter's member ('{x: B.x + 0})", "'{x: B.x + 0}", "   parameter info_t B = info_t'(16);\n")
one('j11', 'an arithmetic of an int localparam initialized by a cast (W + 0, W = int\'(16))', 'W + 0', "   localparam int W = int'(16);\n")
one('j12', "an untyped pattern with a negated member ('{x: -(-16)})", "'{x: -(-16)}")
one('j13', 'the three-instance-free control: an untyped pattern of a literal', "'{x: 16}")

# decode shapes for the refinement's boundary (r11u233)
one('j14', 'a concatenation holding an int cast ({int\'(16)})', "{int'(16)}")
one('j15', "an untyped pattern reading an untyped struct parameter of another type ('{x: C.y})", "'{x: C.y}", "   typedef struct packed { int z; int y; } c_t;\n   parameter c_t C = '{z: 1, y: 16};\n")
one('j17', "an untyped pattern of an int localparam read from a cast struct parameter's member ('{x: W}, W = B.x)", "'{x: W}", "   parameter info_t B = info_t'(16);\n   localparam int W = B.x;\n")
one('j18', 'a parenthesized untyped struct parameter ((B))', '(B)', "   parameter info_t B = '{x: 16};\n")
one('j19', "two hops through members, the far root a cast ('{x: B.x}, B = '{x: C.x}, C cast)", "'{x: B.x}", "   parameter info_t C = info_t'(16);\n   parameter info_t B = '{x: C.x};\n")
one('j20', "two hops through members, the far root untyped ('{x: B.x}, B = '{x: C.x}, C untyped)", "'{x: B.x}", "   parameter info_t C = '{x: 16};\n   parameter info_t B = '{x: C.x};\n")
one('j21', "an int cast of an untyped struct parameter inside a pattern ('{x: int'(B)})", "'{x: int'(B)}", "   parameter info_t B = '{x: 16};\n")
one('j22', 'a subtraction of two literals inside a concatenation beside a struct-free replication', "{{1{16'd0}}, 16'd0, 16'd20 - 16'd4}")

one('j23', 'a concatenation holding an int localparam ({16\'d0, W})', "{16'd0, W}", "   localparam logic [15:0] W = 16;\n")
one('j24', "an untyped pattern whose member is an arithmetic of literals ('{x: 8 + 8})", "'{x: 8 + 8}")
one('j25', 'a concatenation holding a size cast ({16\'d0, 16\'(20)})', "{16'd0, 16'(20)}")
one('j26', 'a concatenation holding a parenthesized literal ({16\'d0, (16\'d16)})', "{16'd0, (16'd16)}")
one('j27', 'a concatenation holding a conditional of literals', "{16'd0, SEL ? 16'd16 : 16'd9}")
one('j28', 'a concatenation holding a subtraction alone ({16\'d20 - 16\'d4})', "{32'd20 - 32'd4}")
one('j29', "a concatenation holding a unary minus of a literal ({16'd0, -16'sd16})", "{16'd0, -16'sd16}")
one('j30', "an untyped pattern whose member is an int localparam of an arithmetic of literals ('{x: W}, W = 8 + 8)", "'{x: W}", "   localparam int W = 8 + 8;\n")

one('j31', 'a concatenation of literals wider than the struct ({16\'d0, 16\'d0, 16\'d16})', "{16'd0, 16'd0, 16'd16}")
one('j32', 'a concatenation of literals narrower than the struct ({8\'d0, 16\'d16})', "{8'd0, 16'd16}")
one('j33', 'a concatenation wider than the struct with a subtraction ({16\'d0, 32\'d20 - 32\'d4})', "{16'd0, 32'd20 - 32'd4}")
print('ok')
