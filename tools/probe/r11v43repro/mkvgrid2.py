import os, sys
ROOT = sys.argv[1]
PKG = """package pk;
  typedef struct packed { logic [31:0] a; logic [15:0] b; logic [7:0] c; } st_t;
  typedef struct packed { logic [3:0] p; logic [3:0] q; } s8_t;
  typedef enum logic [7:0] { E0, E1 } e_t;
endpackage
"""
A = {}
def M(body, ports="", name="top"): return PKG + "module %s(%s);\n%s\nendmodule\n"%(name,ports,body)
# --- type-parameter refinement (v36 anomaly)
def TP(default, override):
    o = "" if override is None else " #(.T(%s))"%override
    return (PKG + "module sub #(parameter type T = %s) (input logic clk);\n  T [2:0] x;\n  assign x = '0;\nendmodule\n"%default
            + "module top(input logic clk);\n  sub%s u(.clk(clk));\nendmodule\n"%o)
A['w01'] = TP("logic", "pk::st_t")            # i10 shape: golden 56
A['w02'] = TP("pk::s8_t", "pk::st_t")         # v36 shape: golden -1?
A['w03'] = TP("logic", None)                  # default logic, no override
A['w04'] = TP("logic [7:0]", "pk::st_t")      # default vector, overridden
A['w05'] = TP("pk::st_t", "pk::st_t")         # same struct override
A['w06'] = TP("pk::e_t", "pk::st_t")          # enum default -> struct
A['w07'] = TP("pk::st_t", "pk::s8_t")         # struct -> narrower struct
# --- write-site / context faces
A['w08'] = M("  pk::st_t [2:0] x = '0;\n  pk::st_t [2:0] y;\n  assign y = '0;\n", "input logic clk")
A['w09'] = M("  pk::st_t [63:0] x;\n  assign x = '0;\n", "input logic clk")   # 3584 bits
A['w10'] = M("  pk::st_t [2:0] x [1:0];\n  assign x[0] = '0;\n", "input logic clk")
A['w11'] = "`default_nettype none\n" + M("  pk::st_t [2:0] x;\n  assign x = '0;\n", "input logic clk")
A['w12'] = M("  (* keep *) pk::st_t [2:0] x;\n  assign x = '0;\n", "input logic clk")
A['w13'] = M("  pk::st_t [2:0] x;\n  assign top.x = '0;\n", "input logic clk")
A['w14'] = PKG + "module top(inout pk::st_t [2:0] io, input logic clk);\n  assign io = '0;\nendmodule\n"
A['w15'] = PKG + "interface ifc(input logic clk);\n  pk::st_t [2:0] x;\n  assign x = '0;\nendinterface\nmodule top(input logic clk);\n  ifc i0(.clk(clk));\nendmodule\n"
A['w16'] = PKG + "program p(input logic clk);\n  initial ;\nendprogram\nmodule top(input logic clk);\n  pk::st_t [2:0] x;\n  assign x = '0;\n  p p0(.clk(clk));\nendmodule\n"
A['w17'] = M("  generate for (genvar g=0; g<2; g++) begin : b\n    pk::st_t [2:0] x;\n  end endgenerate\n  assign b[0].x = '0;\n", "input logic clk")
A['w18'] = M("  typedef struct packed { logic [31:0] a; } lo_t;\n  lo_t [2:0] x;\n  assign x = '0;\n  assign x = '0;\n", "input logic clk")
A['w19'] = PKG + "module top #(parameter int W = 3) (input logic clk);\n  pk::st_t [W-1:0] x;\n  assign x = '0;\nendmodule\n"
A['w20'] = M("  pk::st_t [2:0] x;\n  assign x = pk::st_t'('0);\n", "input logic clk")
for a in sorted(A):
    d = os.path.join(ROOT, a); os.makedirs(d, exist_ok=True)
    open(os.path.join(d,"dut.sv"),"w").write(A[a])
print("ARMS", len(A))
