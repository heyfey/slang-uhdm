// § genCaReplCountInst282
package pk; parameter int P = 4; endpackage
module top  #(parameter int P = 4) (input logic [7:0] a [2], input logic [7:0] b, output logic [7:0] z [2]);
  
  if (1) begin : g localparam int w = 0;
    assign z[w] = {P{b[0]}};
  end
endmodule
