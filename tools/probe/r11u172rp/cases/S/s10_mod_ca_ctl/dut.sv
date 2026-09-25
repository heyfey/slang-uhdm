module top #(parameter int W = 8) (input logic [W-1:0] a, input logic [2:0] s, output logic [W-1:0] y);
  assign y = W'($signed(a) >>> s);
endmodule
