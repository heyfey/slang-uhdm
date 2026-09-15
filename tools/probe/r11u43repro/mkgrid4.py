#!/usr/bin/env python3
# r11u43 — GRID 4: the TYPE-PARAMETER and NON-ANSI-PORT boundary.
import os, sys
ROOT = sys.argv[1] if len(sys.argv) > 1 else "/tmp/r11u43_g/grid4"
PK = ("package pk;\n  typedef struct packed { logic [31:0] a; logic [15:0] b; "
      "logic [7:0] c; } st_t;\nendpackage\n")
INL = "struct packed { logic [31:0] a; logic [15:0] b; logic [7:0] c; }"
A = {}
# j01 — a PORT type parameter with a struct DEFAULT, never overridden
A["j01"] = ("module j01 #(parameter type T = %s) (input logic clk);\n"
            "  T [2:0] x;\n  assign x = '0;\nendmodule\n" % INL)
# j02 — a LOCALPARAM type aliasing a PACKAGE struct
A["j02"] = (PK + "module j02 (input logic clk);\n  localparam type T = pk::st_t;\n"
            "  T [2:0] x;\n  assign x = '0;\nendmodule\n")
# j03 — a PORT type parameter OVERRIDDEN with the same package struct
A["j03"] = (PK + "module j03sub #(parameter type T = logic) (input logic clk);\n"
            "  T [2:0] x;\n  assign x = '0;\nendmodule\n"
            "module j03 (input logic clk);\n  j03sub #(.T(pk::st_t)) u (.clk(clk));\nendmodule\n")
# j04 — a LOCALPARAM type inside a CHILD instance
A["j04"] = (PK + "module j04sub (input logic clk);\n  localparam type T = pk::st_t;\n"
            "  T [2:0] x;\n  assign x = '0;\nendmodule\n"
            "module j04 (input logic clk);\n  j04sub u (.clk(clk));\nendmodule\n")
# j05 — NON-ANSI output port, `var` spelled
A["j05"] = (PK + "module j05 (clk, po);\n  input logic clk;\n"
            "  output var pk::st_t [2:0] po;\n  assign po = '0;\nendmodule\n")
# j06 — NON-ANSI output port, `wire` spelled
A["j06"] = (PK + "module j06 (clk, po);\n  input logic clk;\n"
            "  output wire pk::st_t [2:0] po;\n  assign po = '0;\nendmodule\n")
# j07 — a PORT type parameter overridden, target NOT an array (the control)
A["j07"] = (PK + "module j07sub #(parameter type T = logic) (input logic clk);\n"
            "  T x;\n  assign x = '0;\nendmodule\n"
            "module j07 (input logic clk);\n  j07sub #(.T(pk::st_t)) u (.clk(clk));\nendmodule\n")
# j08 — a module TYPEDEF struct inside a CHILD instance (no parameters at all)
A["j08"] = ("module j08sub (input logic clk);\n"
            "  typedef struct packed { logic [31:0] a; logic [15:0] b; logic [7:0] c; } st_t;\n"
            "  st_t [2:0] x;\n  assign x = '0;\nendmodule\n"
            "module j08 (input logic clk);\n  j08sub u (.clk(clk));\nendmodule\n")
# j09 — a PORT type parameter with a struct default in a CHILD, not overridden
A["j09"] = ("module j09sub #(parameter type T = %s) (input logic clk);\n"
            "  T [2:0] x;\n  assign x = '0;\nendmodule\n"
            "module j09 (input logic clk);\n  j09sub u (.clk(clk));\nendmodule\n" % INL)
# j10 — a localparam type ALIASING a port type parameter
A["j10"] = (PK + "module j10sub #(parameter type T = logic) (input logic clk);\n"
            "  localparam type U = T;\n  U [2:0] x;\n  assign x = '0;\nendmodule\n"
            "module j10 (input logic clk);\n  j10sub #(.T(pk::st_t)) u (.clk(clk));\nendmodule\n")
# j11 — the corpus row's own shape, verbatim, isolated
A["j11"] = ("module j11 (input logic clk, output logic [63:0] sum);\n"
            "  localparam type my_t = %s;\n"
            "  my_t        scalar_sig;\n  my_t [2:0]  arr;\n"
            "  assign scalar_sig = '0;\n  assign arr = '0;\n"
            "  assign sum = scalar_sig.a + arr[0].a + arr[2].b;\nendmodule\n" % INL)
for n, t in sorted(A.items()):
    d = os.path.join(ROOT, n); os.makedirs(d, exist_ok=True)
    open(os.path.join(d, "dut.sv"), "w").write("// r11u43 grid4 arm %s\n" % n + t)
print(len(A), "arms ->", ROOT)
