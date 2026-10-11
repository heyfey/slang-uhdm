// § genCaSelBoundNestedOwner282
package pk; parameter int P = 4; endpackage
module top  #(parameter int P = 4) (input logic [7:0] b, output logic [7:0] z, output logic [7:0] zz);
  
  if (1) begin : g
    assign z = b[0 +: P] | 8'd0;
  end
endmodule
module wrap(input logic [7:0] b, output logic [7:0] z, output logic [7:0] zz); top #(.P(5)) u (.b(b), .z(z), .zz(zz)); endmodule
