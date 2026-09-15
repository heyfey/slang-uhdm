import os, sys
ROOT = sys.argv[1] if len(sys.argv)>1 else "/tmp/v11u43_g/grid"
ARMS = {}

PKG = """package pk;
  typedef struct packed { logic [31:0] a; logic [15:0] b; logic [7:0] c; } st_t;
  typedef struct packed { logic [3:0] p; logic [3:0] q; } s8_t;
  typedef enum logic [7:0] { E0, E1 } e_t;
  typedef union packed { logic [7:0] u; logic [7:0] v; } un_t;
  typedef st_t [2:0] arr_t;
endpackage
"""

def M(body, pre="", ports="", name="top"):
    return PKG + pre + "module %s(%s);\n%s\nendmodule\n" % (name, ports, body)

# ---- v01..: the CONVERT face, variations the implementer may not have hit
ARMS['v01'] = M("  pk::st_t [2:0] x;\n  assign x = '0;\n")                    # pkg struct, module body
ARMS['v02'] = M("  pk::e_t [3:0] x;\n  assign x = '0;\n")                     # pkg enum, module body
ARMS['v03'] = M("  pk::un_t [1:0] x;\n  assign x = '0;\n")                    # pkg union, module body
ARMS['v04'] = M("  pk::arr_t [1:0] x;\n  assign x = '0;\n")                   # dim over a TYPEDEF-ARRAY
ARMS['v05'] = M("  pk::st_t [2:0] x;\n  assign x = '0;\n  assign x = '0;\n")  # two drivers (legal-ish)
ARMS['v06'] = M("  localparam int N = 3;\n  pk::st_t [N-1:0] x;\n  assign x = '0;\n")  # param dim
ARMS['v07'] = M("  pk::st_t [0:2] x;\n  assign x = '0;\n")                    # ascending dim
ARMS['v08'] = M("  pk::st_t [2:0][1:0] x;\n  assign x = '0;\n")               # two written dims
ARMS['v09'] = M("  pk::s8_t [1:0] x;\n  assign x = '0;\n")                    # narrow (16 bits)
ARMS['v10'] = M("  typedef struct packed signed { logic signed [7:0] a; } sg_t;\n  sg_t [1:0] x;\n  assign x = '0;\n")
# interface / hierarchy
ARMS['v11'] = PKG + """interface ifc;
  pk::st_t [2:0] x;
  assign x = '0;
endinterface
module top(input logic clk);
  ifc i0();
endmodule
"""
ARMS['v12'] = PKG + """module child(output pk::st_t [2:0] o);
  assign o = '0;
endmodule
module top(input logic clk);
  pk::st_t [2:0] w;
  child c0(.o(w));
endmodule
"""
# generate scopes (landed-law witnesses must stay)
ARMS['v13'] = M("  genvar g;\n  generate for (g=0;g<2;g++) begin : b\n    pk::st_t [2:0] x;\n    assign x = '0;\n  end endgenerate\n")
ARMS['v14'] = M("  generate if (1) begin : b\n    pk::st_t [2:0] x;\n    assign x = '0;\n  end endgenerate\n")
# declined faces (must be UNMOVED)
ARMS['v15'] = M("  var pk::st_t [2:0] x;\n  assign x = '0;\n")                # var keyword
ARMS['v16'] = M("  wire pk::st_t [2:0] x;\n  assign x = '0;\n")               # net keyword
ARMS['v17'] = M("  pk::st_t x;\n  assign x = '0;\n")                          # no dim
ARMS['v18'] = M("  pk::arr_t x;\n  assign x = '0;\n")                         # array IS the typedef
ARMS['v19'] = M("  logic [167:0] x;\n  assign x = '0;\n")                     # plain logic
ARMS['v20'] = M("  struct packed { logic [7:0] a; } [2:0] x;\n  assign x = '0;\n") # anonymous struct elem
# fill kinds at the converting target
ARMS['v21'] = M("  pk::st_t [2:0] x;\n  assign x = '1;\n")
ARMS['v22'] = M("  pk::st_t [2:0] x;\n  assign x = 'x;\n")
ARMS['v23'] = M("  pk::st_t [2:0] x;\n  assign x = 'z;\n")
ARMS['v24'] = M("  pk::st_t [2:0] x;\n  assign x = 168'b0;\n")
ARMS['v25'] = M("  pk::st_t [2:0] x;\n  assign x = 0;\n")
# write sites
ARMS['v26'] = PKG + "module top(output pk::st_t [2:0] o, input logic clk);\n  assign o = '0;\nendmodule\n"
ARMS['v27'] = PKG + "module top(o, clk);\n  output pk::st_t [2:0] o;\n  input logic clk;\n  assign o = '0;\nendmodule\n"
ARMS['v28'] = M("  pk::st_t [2:0] x;\n  always_comb x = '0;\n")
ARMS['v29'] = M("  pk::st_t [2:0] x;\n  initial x = '0;\n")
ARMS['v30'] = M("  pk::st_t [2:0] x;\n  assign x[0] = '0;\n")                 # select LHS
ARMS['v31'] = M("  pk::st_t [2:0] x;\n  assign x[1:0] = '0;\n")               # part select
ARMS['v32'] = M("  pk::st_t [2:0] x;\n  assign x[0].a = '0;\n")               # member
ARMS['v33'] = M("  pk::st_t [2:0] x, y;\n  assign {x,y} = '0;\n")             # concat LHS
ARMS['v34'] = M("  pk::st_t [2:0] x;\n  assign #2 x = '0;\n")                 # delay
# type parameters
ARMS['v35'] = PKG + "module top #(parameter type T = pk::st_t) (input logic clk);\n  T [2:0] x;\n  assign x = '0;\nendmodule\n"
ARMS['v36'] = PKG + """module chi #(parameter type T = pk::s8_t) (input logic clk);
  T [2:0] x;
  assign x = '0;
endmodule
module top(input logic clk);
  chi #(.T(pk::st_t)) c0(.clk(clk));
endmodule
"""
ARMS['v37'] = PKG + """module chi #(parameter type T = pk::st_t) (input logic clk);
  T [2:0] x;
  assign x = '0;
endmodule
module top(input logic clk);
  chi c0(.clk(clk));
endmodule
"""
ARMS['v38'] = M("  localparam type T = pk::st_t;\n  T [2:0] x;\n  assign x = '0;\n")
# two instances of the same child (elaborated twice)
ARMS['v39'] = PKG + """module chi(input logic clk);
  pk::st_t [2:0] x;
  assign x = '0;
endmodule
module top(input logic clk);
  chi a0(.clk(clk));
  chi a1(.clk(clk));
endmodule
"""
# $unit scope typedef
ARMS['v40'] = """typedef struct packed { logic [7:0] a; } u_t;
module top(input logic clk);
  u_t [2:0] x;
  assign x = '0;
endmodule
"""
# nested: struct containing a packed array, with a written dim
ARMS['v41'] = M("  typedef struct packed { logic [1:0][3:0] m; } n_t;\n  n_t [2:0] x;\n  assign x = '0;\n")
# enum with a dim at a port
ARMS['v42'] = PKG + "module top(output pk::e_t [2:0] o, input logic clk);\n  assign o = '0;\nendmodule\n"
# a target also read elsewhere
ARMS['v43'] = M("  pk::st_t [2:0] x;\n  logic [167:0] y;\n  assign x = '0;\n  assign y = x;\n")
# interface port / modport
ARMS['v44'] = PKG + """interface ifc; pk::st_t [2:0] x; modport mp(output x); endinterface
module chi(ifc.mp p); assign p.x = '0; endmodule
module top(input logic clk); ifc i0(); chi c0(i0); endmodule
"""
# a dim over a struct typedef nested two deep
ARMS['v45'] = M("  typedef pk::st_t q_t;\n  typedef q_t r_t;\n  r_t [2:0] x;\n  assign x = '0;\n")

for a in sorted(ARMS):
    d = os.path.join(ROOT, a)
    os.makedirs(d, exist_ok=True)
    open(os.path.join(d, "dut.sv"), "w").write(ARMS[a])
print("ARMS", len(ARMS))
