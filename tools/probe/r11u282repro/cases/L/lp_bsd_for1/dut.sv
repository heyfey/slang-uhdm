// § genCaLhsIpsBoundInPlace282
module top  (input logic [7:0] a, output logic [7:0] o [3]);
  localparam int P = 4;
  for (genvar x = 0; x < 2; x++) begin : gx
    
    logic [7:0] v;
    assign v[P] = '1;
    assign o[x] = v;
  end
endmodule
