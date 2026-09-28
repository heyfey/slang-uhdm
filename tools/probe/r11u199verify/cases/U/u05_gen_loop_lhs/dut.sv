// § caUnsizedRhsClonePerInst193
module m (input logic c, input logic [7:0] x, output logic [7:0] y [3]);
  for (genvar i = 0; i < 3; i++) begin : g
    assign y[i] = c ? x : '1;
  end
endmodule
module top (input logic c, input logic [7:0] x, output logic [7:0] a [3], output logic [7:0] b [3]);
  m u_a (.c(c), .x(x), .y(a));
  m u_b (.c(c), .x(x), .y(b));
endmodule
