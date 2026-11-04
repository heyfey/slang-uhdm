// § genCaSelBoundNestedOwner282
package pk; parameter int P = 4; endpackage
module top  #(parameter int P = 4) (input logic [7:0] b, output logic [7:0] z, output logic [7:0] zz);
  
  for (genvar k = 0; k < 1; k++) begin : g
    
    assign z = {4'b0, b[P +: 4]};
  end
endmodule
module wrap(input logic [7:0] b, output logic [7:0] z, output logic [7:0] zz); top #(.P(3)) u (.b(b), .z(z), .zz(zz)); endmodule
