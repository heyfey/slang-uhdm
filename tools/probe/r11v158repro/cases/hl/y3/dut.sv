// § arrQueryParamArgOnly158v
module top(input logic clk);
  logic [5:2] v;
  always_ff @(posedge clk) v <= '0;
  parameter low = $low(v);
endmodule
