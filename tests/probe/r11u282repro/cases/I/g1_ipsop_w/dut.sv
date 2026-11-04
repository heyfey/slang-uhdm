// § genCaSelBoundNestedOwner282
module top (input logic [7:0] b, output logic [7:0] z, output logic [7:0] zz);
  if (1) begin : g
    localparam int P = 4;
    if (1) begin : h
      
      assign z = b[P +: 2] | 8'd0;
    end
  end
endmodule
module wrap(input logic [7:0] b, output logic [7:0] z, output logic [7:0] zz); top u (.b(b), .z(z), .zz(zz)); endmodule
