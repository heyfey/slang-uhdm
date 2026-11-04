// § genCaLhsIpsBoundInPlace282
module top #(parameter int P = 2) (output logic [7:0] o [2]);
  for (genvar g = 0; g < 2; g++) begin : gb
    logic [7:0] v;
    assign v[g*2 +: P] = 2'b10;
    assign v[7:4] = '0;
    assign o[g] = v;
  end
endmodule
