// § genCaLhsIpsBoundInPlace282
module top  (input logic [7:0] a, output logic [7:0] o [3]);
  localparam int P = 4;
  if (1) begin : gx
    
    logic [7:0] v;
    assign v[P +: 2] = '1;
    assign o[0] = v;
  end
endmodule
