// § oneTickUpperBNormalized425
module top(input logic a, output logic [3:0] y, output logic [1:0] z);
  logic r;
  initial begin
    r = 1'BX;
    r = 1'Bx;
  end
  assign y = {1'Bx, a, 1'B1, 1'B0};
  assign z = {1'BX, 1'Bx};
endmodule
