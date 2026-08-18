// v62a — PARAM-DEPENDENT module-local typedef WIDTHS across specializations.
// The law claims Surelog shares ONE typespec per DEFINITION for every
// instance.  If that is true even when the typedef's WIDTH depends on a
// parameter, golden must show the same object in both instances.  If golden
// specializes, the patch mis-shares.
module pw62 #(parameter int W = 8) (
  input  logic         clk,
  output logic [W-1:0] dout,
  output logic         f
);
  typedef logic [W-1:0]        w_t;      // width depends on W
  typedef logic [W-1:0][1:0]   wa_t;
  typedef struct packed { logic [W-1:0] a; logic b; } ws_t;
  typedef enum logic [1:0] { PA, PB, PC } pe_t;

  w_t   wv;
  wa_t  wav;
  ws_t  wsv;
  logic [1:0] tt;

  assign wv   = {W{1'b0}};
  assign wsv  = '{ a: wv, b: 1'b1 };
  assign tt   = (wsv.b) ? 2'b01 : 2'b10;
  assign f    = wsv.b & (tt == 2'b01) & (pe_t'(tt) == PB);
  assign dout = wv;
endmodule

module top62a (input logic clk, output logic [15:0] o);
  logic [7:0] d8; logic [15:0] d16; logic fa, fb;
  pw62 #(.W(8))  u_a (.clk(clk), .dout(d8),  .f(fa));
  pw62 #(.W(16)) u_b (.clk(clk), .dout(d16), .f(fb));
  assign o = d16 ^ {7'b0, fa, d8} ^ {15'b0, fb};
endmodule
