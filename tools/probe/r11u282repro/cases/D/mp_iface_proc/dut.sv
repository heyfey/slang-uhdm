// § genProcOpFoldInPlace282
package pk; parameter int P = 4; endpackage
interface ifc  #(parameter int P = 4) (input logic [7:0] b);
  logic [7:0] a [2];
  logic [7:0] z [2];
  if (1) begin : g
    always_comb z[0] = a[0][P-1] ? b + (P - 1) : {P{1'b0}};
    always_comb z[1] = b[P +: 2];
  end
endinterface
module top(input logic [7:0] b); ifc u (.b(b)); endmodule
