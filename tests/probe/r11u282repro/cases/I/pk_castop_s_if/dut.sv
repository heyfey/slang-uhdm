// § genCaSelBoundNestedOwner282
package pk; parameter int P = 4; endpackage
module top import pk::*;  (input logic [7:0] b, output logic [7:0] z, output logic [7:0] zz);
  
  if (1) begin : g
    assign zz[0] = 8'(P) | b;
  end
endmodule
module wrap(input logic [7:0] b, output logic [7:0] z, output logic [7:0] zz); top u (.b(b), .z(z), .zz(zz)); endmodule
