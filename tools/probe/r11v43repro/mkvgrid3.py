import os, sys
ROOT = sys.argv[1]
PKG = """package pk;
  typedef struct packed { logic [31:0] a; logic [15:0] b; logic [7:0] c; } st_t;
  typedef enum logic [7:0] { E0, E1 } e_t;
  typedef union packed { logic [7:0] u; logic [7:0] v; } un_t;
  typedef logic [7:0] b_t;
endpackage
"""
A = {}
def TPD(default):   # port type parameter at its DEFAULT, no override
    return (PKG + "module sub #(parameter type T = %s) (input logic clk);\n  T [2:0] x;\n  assign x = '0;\nendmodule\n"%default
            + "module top(input logic clk);\n  sub u(.clk(clk));\nendmodule\n")
def LP(default):    # localparam type alias
    return (PKG + "module top(input logic clk);\n  localparam type T = %s;\n  T [2:0] x;\n  assign x = '0;\nendmodule\n"%default)
A['x01'] = TPD("pk::e_t")        # ENUM type param at DEFAULT  <-- law claims RAW
A['x02'] = TPD("pk::un_t")       # UNION type param at DEFAULT <-- law claims RAW
A['x03'] = TPD("pk::st_t")       # struct default (j01 analog)
A['x04'] = TPD("pk::b_t")        # logic-typedef default (declined by clause 2)
A['x05'] = LP("pk::e_t")
A['x06'] = LP("pk::un_t")
A['x07'] = LP("pk::st_t")
# anonymous struct/enum type-param defaults
A['x08'] = TPD("struct packed { logic [7:0] a; }")
A['x09'] = TPD("enum logic [7:0] { Q0, Q1 }")
# a type param DEFAULTED to an enum and OVERRIDDEN to an enum
A['x10'] = (PKG + "module sub #(parameter type T = pk::e_t) (input logic clk);\n  T [2:0] x;\n  assign x = '0;\nendmodule\n"
            + "module top(input logic clk);\n  sub #(.T(pk::e_t)) u(.clk(clk));\nendmodule\n")
# a type param DEFAULTED to a union, OVERRIDDEN to a struct
A['x11'] = (PKG + "module sub #(parameter type T = pk::un_t) (input logic clk);\n  T [2:0] x;\n  assign x = '0;\nendmodule\n"
            + "module top(input logic clk);\n  sub #(.T(pk::st_t)) u(.clk(clk));\nendmodule\n")
# nested alias: localparam type aliasing a DEFAULTED port type param
A['x12'] = (PKG + "module sub #(parameter type T = pk::st_t) (input logic clk);\n  localparam type U = T;\n  U [2:0] x;\n  assign x = '0;\nendmodule\n"
            + "module top(input logic clk);\n  sub u(.clk(clk));\nendmodule\n")
A['x13'] = (PKG + "module sub #(parameter type T = pk::e_t) (input logic clk);\n  localparam type U = T;\n  U [2:0] x;\n  assign x = '0;\nendmodule\n"
            + "module top(input logic clk);\n  sub u(.clk(clk));\nendmodule\n")
for a in sorted(A):
    d = os.path.join(ROOT, a); os.makedirs(d, exist_ok=True)
    open(os.path.join(d,"dut.sv"),"w").write(A[a])
print("ARMS", len(A))
