// § parseViewSizeExprEval228 § fwdPkgRefClassScopeSpan227 — a $size whose operand dimension reads a package parameter computed from a forward package reference
package p1;
  localparam int W = $clog2(p2::K);
  typedef struct packed { logic [2:0] x; } s_t;
  localparam s_t S = '{x: p2::E1};
endpackage
package p2;
  typedef enum logic [2:0] {E0, E1, E2} e_t;
  localparam int K = 16;
endpackage
module dut (output logic [7:0] o1, o2);
  bit [p1::W-1:0][1:0] b;
  bit [3:0][p1::S.x:0] c;
  wire [7:0] w1 = $size(b);
  wire [7:0] w2 = $size(c, 2);
  assign o1 = w1; assign o2 = w2;
endmodule
