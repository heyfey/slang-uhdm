// § genCaLhsIpsBoundCloneOnly282
module top #(parameter int P = 4) (input logic [7:0] a, output logic [7:0] o [3]);
  
  for (genvar x = 0; x < 2; x++) begin : gx
    logic [7:0] v;
    assign v[P +: 2] = a[1:0];
    assign o[x] = v;
  end
endmodule
