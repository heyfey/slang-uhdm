// b05: contexts where the constant may be REUSED/SHARED -- range bounds,
// cast width, concat, replication, later parameter refs, generate conditions.
package b05_pkg;
  parameter W = 'h8;
  parameter W2 = W;
  parameter W3 = 'h8 + 0;
  parameter W4 = ('h8);
  parameter W5 = {'h1, 'h2};
  parameter W6 = {2{'h3}};
  parameter W7 = int'('h9);
  parameter W8 = 'h4 ? 'h5 : 'h6;
  parameter W9 = -'h1;
  parameter W10 = ~'h1;
endpackage
module b05_use;
  import b05_pkg::*;
  localparam RB = 'h4;
  logic [RB-1:0] r;
  logic [W-1:0]  q;
  localparam CW = RB'(3);
  if (W > 1) begin : gg
    localparam GG = 'h7;
    initial $display(GG);
  end
  initial $display(r, q, CW, W2, W3, W4, W5, W6, W7, W8, W9, W10);
endmodule
module b05_top;
  b05_use u0();
endmodule
