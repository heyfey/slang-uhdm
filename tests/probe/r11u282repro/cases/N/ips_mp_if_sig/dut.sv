// § genCaLhsIpsBoundCloneOnly282
module top #(parameter int P = 4) (input logic [7:0] a, output logic [7:0] o [3]);
  
  if (1) begin : gx
    logic [7:0] v;
    assign v[P +: 2] = a[1:0];
    assign o[0] = v;
  end
endmodule
