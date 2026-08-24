// r10v79 adversarial arm 9 — the same regression class with a COMPOUND override
// expression (`UU*2`, `UU+1`) instead of a bare name, and with the shadow
// carrying the opposite encoding in each direction.
module child9 #(
  parameter longint Z = 4,
  parameter longint Y = 4
) (input logic clk);
  localparam int          UU = 3 * 2;   // INT-flavoured shadow
  localparam int unsigned VV = 7;       // UINT-flavoured shadow
  logic [7:0] z_arr [Z+1];
  logic [7:0] y_arr [Y+1];
endmodule

module mid9 #(parameter int unsigned N = 4) (input logic clk);
  localparam int unsigned UU = N + 1;   // UINT-flavoured -- the REAL override
  localparam int          VV = N * 3;   // INT-flavoured  -- the REAL override
  child9 #(.Z(UU+1), .Y(VV+1)) u_c (.clk(clk));
endmodule

module top9;
  logic clk;
  mid9 #(.N(5)) u_a (.clk(clk));
  mid9 #(.N(7)) u_b (.clk(clk));
endmodule
