// r10vbuvm24repro/gv24d.sv — SYSTEM calls with empty slots (R-SYS).
module sysv24 (input logic clk, input logic [3:0] x);
  logic [3:0] y;
  always @(posedge clk) begin
    y <= $past(x,,,clk);
  end
  initial $display("%0d", $bits(x));
endmodule
