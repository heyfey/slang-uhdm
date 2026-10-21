// § oneTickUpperBNormalized425
module top(input logic a, output logic y);
  if (1'B1) begin : g
    assign y = a & 1'B1;
  end
endmodule
