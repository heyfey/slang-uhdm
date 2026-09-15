#!/usr/bin/env python3
# r11u43 — GRID 3: the gate's remaining boundary cells.
import os, sys
ROOT = sys.argv[1] if len(sys.argv) > 1 else "/tmp/r11u43_g/grid3"
ST = "    typedef struct packed { logic [31:0] a; logic [15:0] b; logic [7:0] c; } st_t;\n"
S4 = "    typedef struct packed { logic [3:0] a; } s4_t;\n"
A = {}
def M(n, body, ports="(input logic clk)"):
    A[n] = "module %s %s;\n%s\nendmodule\n" % (n, ports, body)

# an ANONYMOUS packed struct carrying a written dimension
M("i01", "    struct packed { logic [31:0] a; logic [23:0] b; } [2:0] w;\n    assign w = '0;\n")
# the aggregate target NARROWER than 64 bits, with '1 (the <=64 mask arm)
M("i02", S4 + "    s4_t [1:0] x;\n    assign x = '1;\n")
# a typedef of an ENUM array (the array inside the name — must DECLINE)
M("i03", "    typedef enum logic [7:0] { A3, B3 } e_t;\n    typedef e_t [2:0] ea_t;\n"
         "    ea_t x;\n    assign x = '0;\n")
# an UNPACKED dim on top of the packed-aggregate target
M("i04", ST + "    st_t [2:0] x [1:0];\n    assign x[0] = '0;\n")
# the target in a CHILD instance (elaborated twice)
A["i05"] = ("package pk5;\n  typedef struct packed { logic [31:0] a; logic [15:0] b; logic [7:0] c; } st_t;\nendpackage\n"
            "module i05sub (input logic clk);\n  pk5::st_t [2:0] x;\n  assign x = '0;\nendmodule\n"
            "module i05 (input logic clk);\n  i05sub u1 (.clk(clk));\n  i05sub u2 (.clk(clk));\nendmodule\n")
# a comma-list cont_assign mixing a target that fires with one that does not
M("i06", ST + "    st_t [2:0] x;\n    logic [7:0] y;\n    assign x = '0, y = '0;\n")
# the target assigned TWICE
M("i07", ST + "    st_t [2:0] x;\n    logic [167:0] z;\n    assign x = '0;\n    assign z = '0;\n")
# a NON-ANSI port of the target shape
A["i08"] = ("package pk6;\n  typedef struct packed { logic [31:0] a; logic [15:0] b; logic [7:0] c; } st_t;\nendpackage\n"
            "module i08 (clk, po);\n  input logic clk;\n  output pk6::st_t [2:0] po;\n"
            "  assign po = '0;\nendmodule\n")
# an INPUT port of the target shape driven internally is illegal; use inout
A["i09"] = ("package pk7;\n  typedef struct packed { logic [31:0] a; logic [15:0] b; logic [7:0] c; } st_t;\nendpackage\n"
            "module i09 (input logic clk, inout pk7::st_t [2:0] io);\n  assign io = '0;\nendmodule\n")
# a struct type parameter OVERRIDDEN at instantiation
A["i10"] = ("package pk8;\n  typedef struct packed { logic [31:0] a; logic [15:0] b; logic [7:0] c; } st_t;\nendpackage\n"
            "module i10sub #(parameter type T = logic) (input logic clk);\n  T [2:0] x;\n  assign x = '0;\nendmodule\n"
            "module i10 (input logic clk);\n  i10sub #(.T(pk8::st_t)) u (.clk(clk));\nendmodule\n")
# the same target with a DELAY on the assign
M("i11", ST + "    st_t [2:0] x;\n    assign #1 x = '0;\n")
# the target with a drive strength
M("i12", ST + "    wire st_t [2:0] x;\n    assign (strong0, strong1) x = '0;\n")
# a packed array of a CLASS-free typedef chain: typedef of a typedef struct
M("i13", ST + "    typedef st_t st2_t;\n    st2_t [2:0] x;\n    assign x = '0;\n")
for n, t in sorted(A.items()):
    d = os.path.join(ROOT, n); os.makedirs(d, exist_ok=True)
    open(os.path.join(d, "dut.sv"), "w").write("// r11u43 grid3 arm %s\n" % n + t)
print(len(A), "arms ->", ROOT)
