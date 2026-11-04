// § genCaSelBoundNestedOwner282
package pk; parameter int P = 4; endpackage
interface ifc  #(parameter int P = 4) (input logic [7:0] b);
  logic [7:0] z, zz, v;
  if (1) begin : g
    assign z = b[P +: 2] | 8'd0;
    assign zz[7:0] = {P{b[0]}};
    assign v[P +: 2] = b[1:0];
  end
endinterface
module top(input logic [7:0] b); ifc u (.b(b)); endmodule
