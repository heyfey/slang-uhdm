// § oneTickUpperBNormalized425
module top(input logic clk, input logic a, output logic y);
  always_ff @(posedge clk) begin
    if (a == 1'B1) y <= 1'B0;
    else y <= 1'Bx;
  end
endmodule
