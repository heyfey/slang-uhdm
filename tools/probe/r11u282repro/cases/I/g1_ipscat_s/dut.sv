// § genCaSelBoundNestedOwner282
module top (input logic [7:0] b, output logic [7:0] z, output logic [7:0] zz);
  if (1) begin : g
    localparam int P = 4;
    if (1) begin : h
      
      assign zz[7:0] = {4'b0, b[P +: 4]};
    end
  end
endmodule
module wrap(input logic [7:0] b, output logic [7:0] z, output logic [7:0] zz); top u (.b(b), .z(z), .zz(zz)); endmodule
