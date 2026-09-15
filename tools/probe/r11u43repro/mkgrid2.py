#!/usr/bin/env python3
# r11u43 — GRID 2: the WRITE-SITE face.  Does the `var`/`wire`/port keyword on a
# packed-array-of-named-aggregate declaration move golden's fill size?
import os, sys
ROOT = sys.argv[1] if len(sys.argv) > 1 else "/tmp/r11u43_g/grid2"
ST = """    typedef struct packed {
        logic [31:0] a;
        logic [15:0] b;
        logic [7:0]  c;
    } st_t;
"""
TP = """    localparam type my_t = struct packed {
        logic [31:0] a;
        logic [15:0] b;
        logic [7:0]  c;
    };
"""
A = {}
def M(n, body, ports="(input logic clk)"):
    A[n] = "module %s %s;\n%s\nendmodule\n" % (n, ports, body)

M("h01", ST + "    wire st_t [2:0] x;\n    assign x = '0;\n")
M("h02", ST + "    var  st_t [2:0] x;\n    assign x = '0;\n")
M("h03", ST + "    logic st_t_dummy;\n    st_t [2:0] x;\n    assign x = '0;\n")
M("h04", TP + "    wire my_t [2:0] x;\n    assign x = '0;\n")
M("h05", TP + "    var  my_t [2:0] x;\n    assign x = '0;\n")
A["h06"] = ST.replace("    ", "  ") and (
    "package pk;\n  typedef struct packed { logic [31:0] a; logic [15:0] b; logic [7:0] c; } st_t;\nendpackage\n"
    "module h06 (input logic clk);\n    wire pk::st_t [2:0] x;\n    assign x = '0;\nendmodule\n")
A["h07"] = ("module h07 (input logic clk, output wire logic [2:0][7:0] po);\n"
            "    assign po = '0;\nendmodule\n")
A["h08"] = ("package pk2;\n  typedef struct packed { logic [31:0] a; logic [15:0] b; logic [7:0] c; } st_t;\nendpackage\n"
            "module h08 (input logic clk, output pk2::st_t [2:0] po);\n    assign po = '0;\nendmodule\n")
A["h09"] = ("package pk3;\n  typedef struct packed { logic [31:0] a; logic [15:0] b; logic [7:0] c; } st_t;\nendpackage\n"
            "module h09 (input logic clk, output var pk3::st_t [2:0] po);\n    assign po = '0;\nendmodule\n")
M("h10", "    typedef enum logic [7:0] { A2, B2 } e_t;\n    wire e_t [2:0] x;\n    assign x = '0;\n")
M("h11", ST + "    st_t [2:0] x;\n    assign x = '1;\n")
M("h12", ST + "    st_t [2:0] x;\n    logic [167:0] y;\n    assign x = '0;\n    assign y = '0;\n")
# a SUBMODULE instance whose port is the target shape (a write site one hop away)
A["h13"] = ("package pk4;\n  typedef struct packed { logic [31:0] a; logic [15:0] b; logic [7:0] c; } st_t;\nendpackage\n"
            "module h13sub (input pk4::st_t [2:0] i);\nendmodule\n"
            "module h13 (input logic clk);\n    pk4::st_t [2:0] x;\n    assign x = '0;\n"
            "    h13sub u (.i(x));\nendmodule\n")
# the target inside a generate scope (the landed law's own reach, on THIS shape)
M("h14", ST + "    if (1) begin : gb\n      st_t [2:0] x;\n      assign x = '0;\n    end\n")
# an INTERFACE hosting the target
A["h15"] = ("interface h15if (input logic clk);\n"
            "  typedef struct packed { logic [31:0] a; logic [15:0] b; logic [7:0] c; } st_t;\n"
            "  st_t [2:0] x;\n  assign x = '0;\nendinterface\n"
            "module h15 (input logic clk);\n  h15if u (.clk(clk));\nendmodule\n")
# a PACKAGE-level target (no cont_assign there; a param control)
M("h16", ST + "    st_t [2:0] x;\n    assign x = 168'b0;\n")
M("h17", ST + "    st_t [2:0] x;\n    assign x = {168{1'b0}};\n")

for n, t in sorted(A.items()):
    d = os.path.join(ROOT, n); os.makedirs(d, exist_ok=True)
    open(os.path.join(d, "dut.sv"), "w").write("// r11u43 grid2 arm %s\n" % n + t)
print(len(A), "arms ->", ROOT)
