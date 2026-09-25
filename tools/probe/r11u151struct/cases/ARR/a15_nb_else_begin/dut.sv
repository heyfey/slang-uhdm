// ARR: nonblocking, the whole read in the same else-begin as the select write.
module top(input logic clk, input logic rst, input logic a, output logic [3:0] y);
  logic [3:0] v;
  always_ff @(posedge clk)
    if (rst) v <= '0;
    else begin
      v[0] <= a;
      y <= v;
    end
endmodule
