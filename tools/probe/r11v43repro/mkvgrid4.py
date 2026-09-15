import os, sys
ROOT = sys.argv[1]
PKG = """package pk;
  typedef struct packed { logic [31:0] a; logic [15:0] b; logic [7:0] c; } st_t;
  typedef enum logic [7:0] { E0, E1 } e_t;
  typedef union packed { logic [7:0] u; logic [7:0] v; } un_t;
endpackage
"""
A = {}
# plain typedef-of-typedef (NOT a type parameter) for enum / union
A['y01'] = PKG + "module top(input logic clk);\n  typedef pk::e_t q_t;\n  q_t [2:0] x;\n  assign x = '0;\nendmodule\n"
A['y02'] = PKG + "module top(input logic clk);\n  typedef pk::un_t q_t;\n  q_t [2:0] x;\n  assign x = '0;\nendmodule\n"
A['y03'] = PKG + "module top(input logic clk);\n  typedef pk::st_t q_t;\n  q_t [2:0] x;\n  assign x = '0;\nendmodule\n"
# enum / union at a PORT via a plain typedef
A['y04'] = PKG + "module top(output pk::un_t [2:0] o, input logic clk);\n  assign o = '0;\nendmodule\n"
# enum through a type param, at a PORT
A['y05'] = (PKG + "module sub #(parameter type T = pk::e_t) (output T [2:0] o, input logic clk);\n  assign o = '0;\nendmodule\n"
            + "module top(input logic clk);\n  pk::e_t [2:0] w;\n  sub u(.o(w), .clk(clk));\nendmodule\n")
# struct through a type param, at a PORT
A['y06'] = (PKG + "module sub #(parameter type T = pk::st_t) (output T [2:0] o, input logic clk);\n  assign o = '0;\nendmodule\n"
            + "module top(input logic clk);\n  pk::st_t [2:0] w;\n  sub u(.o(w), .clk(clk));\nendmodule\n")
# a localparam type aliasing a plain enum typedef, two hops
A['y07'] = PKG + "module top(input logic clk);\n  typedef pk::e_t q_t;\n  localparam type T = q_t;\n  T [2:0] x;\n  assign x = '0;\nendmodule\n"
# a plain typedef of a LOCALPARAM TYPE enum
A['y08'] = PKG + "module top(input logic clk);\n  localparam type T = pk::e_t;\n  typedef T q_t;\n  q_t [2:0] x;\n  assign x = '0;\nendmodule\n"
# struct counterparts of y07/y08
A['y09'] = PKG + "module top(input logic clk);\n  typedef pk::st_t q_t;\n  localparam type T = q_t;\n  T [2:0] x;\n  assign x = '0;\nendmodule\n"
A['y10'] = PKG + "module top(input logic clk);\n  localparam type T = pk::st_t;\n  typedef T q_t;\n  q_t [2:0] x;\n  assign x = '0;\nendmodule\n"
for a in sorted(A):
    d = os.path.join(ROOT, a); os.makedirs(d, exist_ok=True)
    open(os.path.join(d,"dut.sv"),"w").write(A[a])
print("ARMS", len(A))
