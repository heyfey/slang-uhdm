// v11u49 arm v2 — LAW A: unpacked package struct param with a SYMBOLIC member dim,
// and the default:-only pattern, both read scoped.
package p;
  localparam int W = 8;
  typedef struct { logic [W-1:0] a; logic [W-1:0] b; } sym_t;
  typedef struct { logic [7:0] a; logic [7:0] b; } fix_t;
  localparam sym_t SYM = '{a:8'd1, b:8'd2};
  localparam fix_t DEF = '{default: 8'd7};
  localparam fix_t MIX = '{a:8'd3, default: 8'd9};
endpackage
module v2 (output logic [31:0] o);
  assign o = p::SYM.a + p::DEF.a + p::MIX.b;
endmodule
