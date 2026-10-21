// § oneTickUpperBNormalized425
module top(input logic a, output logic [1:0] y);
  parameter logic [1:0] P = {1'B1, 1'B0};
  assign y = P ^ {a, 1'B1};
endmodule
