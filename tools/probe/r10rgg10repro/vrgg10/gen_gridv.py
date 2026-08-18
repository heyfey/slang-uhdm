#!/usr/bin/env python3
# vrgg10 adversarial grid generator: break § genLpPortConnRead10.
import os, sys, shutil
OUT = sys.argv[1] if len(sys.argv) > 1 else '/tmp/vrgg10_grid'
if os.path.isdir(OUT): shutil.rmtree(OUT)
os.makedirs(OUT)

SINKS = """
module sink #(parameter int W = 8) (input logic [7:0] i_value);
endmodule
module wsink (input logic [15:0] i_value);
endmodule
module nsink (input logic [3:0] i_value);
endmodule
module rsink (input real i_value);
endmodule
module ssink (input string i_value);
endmodule
module twosink (input logic [7:0] a, input logic [7:0] b);
endmodule
module osink (input logic [7:0] i_value, output logic [7:0] o_value);
endmodule
"""

def emit(name, src):
    d = os.path.join(OUT, name)
    os.makedirs(d, exist_ok=True)
    with open(os.path.join(d, 'top.sv'), 'w') as f:
        f.write(SINKS + src)

# ------------------------------------------------------------------ F1: READ
DECL = "localparam bit [7:0] IV = 8'hab;"
READS = {
 'none'        : "",
 'portplain'   : "sink #(8) u (.i_value(IV));",
 'portpos'     : "sink #(8) u (IV);",
 'portwide'    : "wsink u (.i_value(IV));",
 'portnarrow'  : "nsink u (.i_value(IV));",
 'portsel'     : "sink #(8) u (.i_value({4'h0, IV[3:0]}));",
 'portbit'     : "sink #(8) u (.i_value({7'h0, IV[0]}));",
 'portcatbare' : "sink #(8) u (.i_value({IV}));",
 'portexpr'    : "sink #(8) u (.i_value(IV + 1));",
 'portunary'   : "sink #(8) u (.i_value(~IV));",
 'portternary' : "sink #(8) u (.i_value(1'b1 ? IV : 8'h0));",
 'portternsel' : "sink #(8) u (.i_value(1'b1 ? {4'h0,IV[3:0]} : 8'h0));",
 'portcast'    : "sink #(8) u (.i_value(8'(IV)));",
 'portcastsel' : "sink #(8) u (.i_value(8'({4'h0,IV[3:0]})));",
 'portcastbit' : "sink #(8) u (.i_value(8'(IV[3:0])));",
 'portcall'    : "sink #(8) u (.i_value(f8(IV)));",
 'portcallsel' : "sink #(8) u (.i_value(f8({4'h0,IV[3:0]})));",
 'portrepl'    : "sink #(8) u (.i_value({2{IV[3:0]}}));",
 'portreplbare': "sink #(8) u (.i_value({1{IV}}));",
 'portsigned'  : "sink #(8) u (.i_value($signed(IV)));",
 'ca'          : "wire [7:0] wr; assign wr = IV;",
 'caexpr'      : "wire [7:0] wr; assign wr = IV + 1;",
 'cafun'       : "wire [7:0] wr; assign wr = f8(IV);",
 'calhsidx'    : "wire [7:0] wr; assign wr[IV[0]] = 1'b0;",
 'pov'         : "sink #(.W(IV)) u (.i_value(8'h0));",
 'povsel'      : "sink #(.W(IV[3:0])) u (.i_value(8'h0));",
 'both'        : "sink #(.W(IV)) u (.i_value(IV));",
 'portarray'   : "sink #(8) u [1:0] (.i_value(IV));",
 'port2darr'   : "sink #(8) u [1:0][1:0] (.i_value(IV));",
 'portnested'  : "if (1) begin : h sink #(8) u (.i_value(IV)); end",
 'portnestfor' : "for (genvar k = 0; k < 2; k++) begin : h sink #(8) u (.i_value(IV)); end",
 'portuninst'  : "if (0) begin : h sink #(8) u (.i_value(IV)); end",
 'portmixed'   : "twosink u (.a(IV), .b(8'h0));",
 'portmixed2'  : "twosink u (.a(8'h0), .b(IV));",
 'portout'     : "wire [7:0] ow; osink u (.i_value(IV), .o_value(ow));",
 'portnoconn'  : "sink #(8) u ();",
 'portconstonly':"sink #(8) u (.i_value(8'hab));",
 'twoinst'     : "sink #(8) u0 (.i_value(IV)); sink #(8) u1 (.i_value(8'h0));",
 'twoinstboth' : "sink #(8) u0 (.i_value(IV)); sink #(8) u1 (.i_value(IV));",
 'threeinst'   : "sink #(8) u0 (.i_value(8'h0)); sink #(8) u1 (.i_value(8'h1)); sink #(8) u2 (.i_value(IV));",
 'ifacegeninst': "",   # handled separately
}
F1TOP = """
module top;
  function automatic logic [7:0] f8(input logic [7:0] a); return a; endfunction
  if (1) begin : g
    %s
    %s
  end
endmodule
"""
for rn, rsrc in READS.items():
    if rn == 'ifacegeninst': continue
    emit('f1__' + rn, F1TOP % (DECL, rsrc))

# a second localparam in the same scope that nothing reads (leak check)
emit('f1__siblinglp', """
module top;
  if (1) begin : g
    localparam bit [7:0] IV = 8'hab;
    localparam bit [7:0] JV = 8'h5c;
    sink #(8) u (.i_value(IV));
  end
endmodule
""")
# read from a SIBLING gen scope via hierarchical name
emit('f1__hiersibling', """
module top;
  if (1) begin : g
    localparam bit [7:0] IV = 8'hab;
  end
  if (1) begin : h
    sink #(8) u (.i_value(top.g.IV));
  end
endmodule
""")
# read at MODULE BODY of a gen-scope localparam
emit('f1__hiermodbody', """
module top;
  if (1) begin : g
    localparam bit [7:0] IV = 8'hab;
  end
  sink #(8) u (.i_value(g.IV));
endmodule
""")
# interface instance inside the gen scope (no ports) plus the port read
emit('f1__ifaceinst', """
interface myif; logic x; endinterface
module top;
  if (1) begin : g
    localparam bit [7:0] IV = 8'hab;
    myif ifc();
    sink #(8) u (.i_value(IV));
  end
endmodule
""")
# instance with an INTERFACE port
emit('f1__ifaceport', """
interface myif; logic x; endinterface
module isink (myif p, input logic [7:0] i_value); endmodule
module top;
  if (1) begin : g
    localparam bit [7:0] IV = 8'hab;
    myif ifc();
    isink u (.p(ifc), .i_value(IV));
  end
endmodule
""")
# .* wildcard connection
emit('f1__dotstar', """
module top;
  if (1) begin : g
    localparam bit [7:0] IV = 8'hab;
    wire [7:0] i_value = IV;
    sink #(8) u (.*);
  end
endmodule
""")
# unknown-module instantiation alongside a real port read
emit('f1__unknownmod', """
module top;
  if (1) begin : g
    localparam bit [7:0] IV = 8'hab;
    sink #(8) u (.i_value(IV));
  end
endmodule
""")

# ------------------------------------------------------------------ F2: TYPE
TYPES = {
 'bit8'    : ("localparam bit [7:0] IV = 8'hab;",            "sink #(8) u (.i_value(IV));"),
 'logic8'  : ("localparam logic [7:0] IV = 8'hab;",          "sink #(8) u (.i_value(IV));"),
 'reg8'    : ("localparam reg [7:0] IV = 8'hab;",            "sink #(8) u (.i_value(IV));"),
 'bit1'    : ("localparam bit IV = 1'b1;",                   "sink #(8) u (.i_value({7'h0,IV}));"),
 'bit1p'   : ("localparam bit IV = 1'b1;",                   "sink #(8) u (.i_value(IV));"),
 'logic1'  : ("localparam logic IV = 1'b1;",                 "sink #(8) u (.i_value(IV));"),
 'int'     : ("localparam int IV = 171;",                    "sink #(8) u (.i_value(IV));"),
 'integer' : ("localparam integer IV = 171;",                "sink #(8) u (.i_value(IV));"),
 'byte'    : ("localparam byte IV = 8'hab;",                 "sink #(8) u (.i_value(IV));"),
 'shortint': ("localparam shortint IV = 171;",               "sink #(8) u (.i_value(IV));"),
 'longint' : ("localparam longint IV = 171;",                "sink #(8) u (.i_value(IV));"),
 'untyped' : ("localparam IV = 8'hab;",                      "sink #(8) u (.i_value(IV));"),
 'sbit8'   : ("localparam bit signed [7:0] IV = 8'hab;",     "sink #(8) u (.i_value(IV));"),
 'slog8'   : ("localparam logic signed [7:0] IV = 8'hab;",   "sink #(8) u (.i_value(IV));"),
 'ubit8'   : ("localparam bit unsigned [7:0] IV = 8'hab;",   "sink #(8) u (.i_value(IV));"),
 'bit2d'   : ("localparam bit [1:0][3:0] IV = 8'hab;",       "sink #(8) u (.i_value(IV));"),
 'bit3d'   : ("localparam bit [1:0][1:0][1:0] IV = 8'hab;",  "sink #(8) u (.i_value(IV));"),
 'bitrev'  : ("localparam bit [0:7] IV = 8'hab;",            "sink #(8) u (.i_value(IV));"),
 'bit31'   : ("localparam bit [3:1] IV = 3'h5;",             "sink #(8) u (.i_value({5'h0,IV}));"),
 'bitunp'  : ("localparam bit [7:0] IV [0:1] = '{8'hab,8'h5c};", "sink #(8) u (.i_value(IV[0]));"),
 'tdef'    : ("typedef bit [7:0] t8_t; localparam t8_t IV = 8'hab;", "sink #(8) u (.i_value(IV));"),
 'tdefr'   : ("typedef bit [7:0] t8_t; typedef t8_t t8b_t; localparam t8b_t IV = 8'hab;", "sink #(8) u (.i_value(IV));"),
 'enum8'   : ("typedef enum bit [7:0] { E0 = 8'hab } e_t; localparam e_t IV = E0;", "sink #(8) u (.i_value(IV));"),
 'struct8' : ("typedef struct packed { bit [3:0] a; bit [3:0] b; } s_t; localparam s_t IV = 8'hab;", "sink #(8) u (.i_value(IV));"),
 'union8'  : ("typedef union packed { bit [7:0] a; bit [7:0] b; } u_t; localparam u_t IV = 8'hab;", "sink #(8) u (.i_value(IV));"),
 'real'    : ("localparam real IV = 1.5;",                   "rsink u (.i_value(IV));"),
 'string'  : ("localparam string IV = \"ab\";",              "ssink u (.i_value(IV));"),
 'time'    : ("localparam time IV = 171;",                   "sink #(8) u (.i_value(IV));"),
 'param8'  : ("parameter bit [7:0] IV = 8'hab;",             "sink #(8) u (.i_value(IV));"),
 'bitN'    : ("localparam int WW = 8; localparam bit [WW-1:0] IV = 8'hab;", "sink #(8) u (.i_value(IV));"),
}
for tn, (d, r) in TYPES.items():
    emit('f2__' + tn, F1TOP % (d, r))
    emit('f2none__' + tn, F1TOP % (d, ""))

# ------------------------------------------------------------------ F3: SCOPE
S = "localparam bit [7:0] IV = 8'hab;"
R = "sink #(8) u (.i_value(IV));"
emit('f3__topgen',  F1TOP % (S, R))
emit('f3__topfor',  "module top;\n for (genvar i=0;i<2;i++) begin : g\n %s\n %s\n end\nendmodule\n" % (S, R))
emit('f3__topcase', "module top;\n case (1)\n 1: begin : g\n %s\n %s\n end\n endcase\nendmodule\n" % (S, R))
emit('f3__nestgen', "module top;\n if (1) begin : g\n if (1) begin : h\n %s\n %s\n end\n end\nendmodule\n" % (S, R))
emit('f3__gennoname', "module top;\n if (1) begin\n %s\n %s\n end\nendmodule\n" % (S, R))
emit('f3__gennestunnamed', "module top;\n if (1) begin : g\n if (1) begin\n %s\n %s\n end\n end\nendmodule\n" % (S, R))
emit('f3__genelse', "module top;\n if (0) begin : g\n %s\n %s\n end else begin : e\n %s\n %s\n end\nendmodule\n" % (S,R,S,R))
CH = "module child;\n if (1) begin : g\n %s\n %s\n end\nendmodule\n" % (S, R)
emit('f3__childgen1', CH + "module top; child c0(); endmodule\n")
emit('f3__childgen2', CH + "module top; child c0(); child c1(); endmodule\n")
emit('f3__childgen3', CH + "module top; child c0(); child c1(); child c2(); endmodule\n")
emit('f3__ifacegen', "interface myif;\n if (1) begin : g\n %s\n %s\n end\nendinterface\nmodule top; myif ifc(); endmodule\n" % (S, R))
emit('f3__pgmgen',  "program pgm;\n if (1) begin : g\n %s\n end\n initial begin end\nendprogram\nmodule top; pgm p(); endmodule\n" % (S,))
emit('f3__modbody', "module top;\n %s\n %s\nendmodule\n" % (S, R))
emit('f3__pkg',     "package pk;\n %s\nendpackage\nmodule top;\n sink #(8) u (.i_value(pk::IV));\nendmodule\n" % (S,))
emit('f3__unit',    "%s\nmodule top;\n sink #(8) u (.i_value(IV));\nendmodule\n" % (S,))
emit('f3__genincase', "module top;\n if (1) begin : g\n case (1)\n 1: begin : h\n %s\n %s\n end\n endcase\n end\nendmodule\n" % (S, R))
emit('f3__forinif', "module top;\n if (1) begin : g\n for (genvar i=0;i<2;i++) begin : h\n %s\n %s\n end\n end\nendmodule\n" % (S, R))

# ------------------------------------------------------------------ F4: INIT
INITS = {
 'nz'      : "8'hab", 'zero': "8'h00", 'unsized': "171", 'bin': "8'b10101011",
 'oct'     : "8'o253", 'dec': "8'd171", 'neg': "-8'd1", 'concat': "{4'ha,4'hb}",
 'repl'    : "{2{4'hb}}", 'cast': "8'(171)", 'xz': "8'hx", 'zval': "8'hz",
 'clog2'   : "8'($clog2(256))", 'sized64': "64'hab",
}
for iname, ival in INITS.items():
    emit('f4__' + iname, F1TOP % ("localparam bit [7:0] IV = %s;" % ival, R))
emit('f4__pexpr', """
module top;
  parameter int P = 4;
  if (1) begin : g
    localparam bit [7:0] IV = P + 1;
    sink #(8) u (.i_value(IV));
  end
endmodule
""")
emit('f4__call', """
module top;
  function automatic logic [7:0] f8(input logic [7:0] a); return a; endfunction
  if (1) begin : g
    localparam bit [7:0] IV = f8(8'hab);
    sink #(8) u (.i_value(IV));
  end
endmodule
""")

# ------------------------------------------------------------------ F5: OVERRIDES
emit('f5__ovwidth', """
module child #(parameter int W = 8);
  if (1) begin : g
    localparam bit [W-1:0] IV = 8'hab;
    sink #(8) u (.i_value(IV));
  end
endmodule
module top;
  child #(8) c0();
  child #(4) c1();
  child #(16) c2();
endmodule
""")
emit('f5__ovval', """
module child #(parameter bit [7:0] V = 8'hab);
  if (1) begin : g
    localparam bit [7:0] IV = V;
    sink #(8) u (.i_value(IV));
  end
endmodule
module top;
  child #(8'hab) c0();
  child #(8'h00) c1();
  child #(8'h5c) c2();
endmodule
""")
emit('f5__defparam', """
module child #(parameter int W = 8);
  if (1) begin : g
    localparam bit [7:0] IV = 8'hab;
    sink #(8) u (.i_value(IV));
  end
endmodule
module top;
  child c0();
  defparam c0.W = 4;
endmodule
""")
emit('f5__gencond', """
module child #(parameter int W = 8);
  if (W > 4) begin : g
    localparam bit [7:0] IV = 8'hab;
    sink #(8) u (.i_value(IV));
  end else begin : e
    localparam bit [7:0] IV = 8'h5c;
    sink #(8) u (.i_value(IV));
  end
endmodule
module top; child #(8) c0(); child #(2) c1(); endmodule
""")
emit('f5__forbody', """
module top;
  for (genvar i = 0; i < 3; i++) begin : g
    localparam bit [7:0] IV = 8'hab + i;
    sink #(8) u (.i_value(IV));
  end
endmodule
""")
print("cells=%d" % len(os.listdir(OUT)))
