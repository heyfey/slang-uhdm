// v82 adversarial arm V2 — THE OVERRIDE-ACTUAL-IS-A-NAME shapes the pass's
// grid does NOT contain: the named parameter's initialiser is a BASED literal,
// the named parameter is WIDER THAN 64, the named parameter is UNTYPED with an
// EXPRESSION initialiser, a THREE-hop name chain, and a name chain whose root
// is a package parameter.  Each is a shape where the old litBoundOwnPar9 and
// the new ovActualStoredWidth82 answer DIFFERENTLY.  MEASUREMENT ONLY.
package pkv2_82;
  localparam int  PBASE = 8;
  localparam byte PBYTE = 8;
endpackage

typedef struct packed { logic [3:0] a; } mv2_t;

module leaf_v2_82 #(parameter int LW = 1) (input logic clk, output logic o);
  logic [LW:0] n_l;
  mv2_t [LW:0] v_l;
  logic [3:0]  u_l [LW:0];
  assign o = clk ^ n_l[0] ^ v_l[0].a[0] ^ u_l[0][0];
endmodule

module mid_v2_82 #(parameter int MW = 1) (input logic clk, output logic o);
  // a THREE-hop chain: top -> mid(MW) -> leaf(LW=MW)
  leaf_v2_82 #(.LW(MW)) i_l (.clk(clk), .o(o));
endmodule

module top_v2_82 (input logic clk,
                  output logic o1, o2, o3, o4, o5, o6, o7);
  localparam int      BASED_LP = 8'd8;      // BASED-literal initialiser
  localparam logic [99:0] WIDE_LP = 8;      // WIDER THAN 64
  localparam          UNT_EXPR  = 4 + 4;    // UNTYPED, EXPRESSION init
  localparam          UNT_LIT   = 8;        // UNTYPED, literal init
  localparam byte     BYTE_LIT  = 8;        // typed narrow, literal init
  leaf_v2_82 #(.LW(BASED_LP)) i1 (.clk(clk), .o(o1));
  leaf_v2_82 #(.LW(WIDE_LP))  i2 (.clk(clk), .o(o2));
  leaf_v2_82 #(.LW(UNT_EXPR)) i3 (.clk(clk), .o(o3));
  leaf_v2_82 #(.LW(UNT_LIT))  i4 (.clk(clk), .o(o4));
  leaf_v2_82 #(.LW(BYTE_LIT)) i5 (.clk(clk), .o(o5));
  leaf_v2_82 #(.LW(pkv2_82::PBYTE)) i6 (.clk(clk), .o(o6));
  mid_v2_82  #(.MW(BYTE_LIT)) i7 (.clk(clk), .o(o7));
endmodule
