// r10v64 ARM 10 — EXOTIC declared types that reach adjustCopiedParamConst64's
// PackedArrayType branch: packed array OF ENUM, 2-D packed array, packed array
// of a typedef'd vector, and a packed struct array (fence).  MEASUREMENT ONLY.
package pv10;
  typedef enum logic [2:0] { Z0 = 3'd0, Z2 = 3'd2 } z_t;
  typedef logic [1:0] pair_t;
  typedef struct packed { logic [1:0] a; logic [1:0] b; } sp_t;
endpackage

module tEArr #(parameter pv10::z_t   [1:0] P = 6'd2)(input c, output [3:0] o);
  localparam int W = 4; if (P != 0) begin : g assign o = c ? W'(P) : P + 1; end
  else begin : g2 assign o = 4'd0; end
endmodule
module t2D   #(parameter logic [3:0][1:0] P = 8'd2)(input c, output [3:0] o);
  localparam int W = 4; if (P != 0) begin : g assign o = c ? W'(P) : P + 1; end
  else begin : g2 assign o = 4'd0; end
endmodule
module tPArr #(parameter pv10::pair_t [1:0] P = 4'd2)(input c, output [3:0] o);
  localparam int W = 4; if (P != 0) begin : g assign o = c ? W'(P) : P + 1; end
  else begin : g2 assign o = 4'd0; end
endmodule
module tSArr #(parameter pv10::sp_t  [1:0] P = 8'd2)(input c, output [3:0] o);
  localparam int W = 4; if (P != 0) begin : g assign o = c ? W'(P[0]) : 4'd1; end
  else begin : g2 assign o = 4'd0; end
endmodule
module tBigV #(parameter logic [63:0] P = 4)(input c, output [3:0] o);
  localparam int W = 4; if (P != 0) begin : g assign o = c ? W'(P) : P + 1; end
  else begin : g2 assign o = 4'd0; end
endmodule
module tB65  #(parameter logic [64:0] P = 4)(input c, output [3:0] o);
  localparam int W = 4; if (P != 0) begin : g assign o = c ? W'(P) : P[3:0] + 1; end
  else begin : g2 assign o = 4'd0; end
endmodule

module topV10(input c);
  localparam int       SI = 1 * 2;
  localparam bit [3:0] SH = 4'h2;
  localparam bit [3:0] SB = 4'b0010;
  wire [3:0] a1,a2,a3,a4,a5,a6,a7,a8,a9,b1,b2,b3,b4,b5,b6,b7,b8,b9,c1,c2,c3,c4;
  tEArr #(.P(6'd2))  e1(c,a1); tEArr #(.P(SH)) e2(c,a2); tEArr #(.P(SB)) e3(c,a3); tEArr e4(c,a4);
  t2D   #(.P(8'd2))  d1(c,a5); t2D   #(.P(SH)) d2(c,a6); t2D   #(.P(SB)) d3(c,a7); t2D   d4(c,a8);
  tPArr #(.P(4'd2))  p1(c,a9); tPArr #(.P(SH)) p2(c,b1); tPArr #(.P(SB)) p3(c,b2); tPArr p4(c,b3);
  tSArr #(.P(8'd2))  s1(c,b4); tSArr #(.P(SH)) s2(c,b5); tSArr s3(c,b6);
  tBigV #(.P(2))     g1(c,b7); tBigV #(.P(SH)) g2(c,b8); tBigV #(.P(SI)) g3(c,b9); tBigV #(.P(SB)) g4(c,c1);
  tB65  #(.P(2))     h1(c,c2); tB65  #(.P(SH)) h2(c,c3); tB65  #(.P(SI)) h3(c,c4);
endmodule
