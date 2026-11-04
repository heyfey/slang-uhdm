// § ppOutputLine166
`define ML(y, x) \
  assign y = \
    x;
module top(input logic [3:0] a, output logic [3:0] y);
  for (genvar i = 0; i < 4; i++) begin : G
    `ML(y[i], a[3-i])
  end
endmodule
