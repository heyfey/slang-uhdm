// § caUnsizedRhsClonePerInst193
module m (input logic c, output logic [3:0] y);
  for (genvar i = 0; i < 2; i++) begin : g
    assign y[i] = c ? 1'b1 : '0;
  end
endmodule
module top (input logic c, output logic [3:0] y1);
  m u_a (.c(c), .y(y1));
endmodule
