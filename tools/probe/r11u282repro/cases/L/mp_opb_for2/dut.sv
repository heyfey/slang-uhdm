// § genCaLhsIpsBoundInPlace282
module top #(parameter int P = 4) (input logic [7:0] a, output logic [7:0] o [3]);
  
  for (genvar x = 0; x < 2; x++) begin : gx
    
    for (genvar y = 0; y < 2; y++) begin : gy
      logic [7:0] v;
      assign v[P-1] = '1;
      assign o[x+y] = v;
    end
  end
endmodule
