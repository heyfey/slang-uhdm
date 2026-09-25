// ARR: or1200_dc_fsm's `addr_r` shape: a nonblocking select WRITE in one
// begin, and in a sibling begin a whole write whose Rhs READS a select of the
// same name (a read never answers lateBinding's lvalue scan: golden keeps the
// net).
module top(input logic clk, input logic c, input logic [1:0] x, output logic [5:0] y);
  logic [5:0] r;
  always @(posedge clk) begin
    if (c) begin
      r[3:2] <= r[3:2] + 2'd1;
    end else begin
      r <= {x, r[3:2], 2'd0};
    end
  end
  assign y = r;
endmodule
