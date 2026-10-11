// § defGenSelRefChainName287
package q; parameter logic [3:0][7:0] A = {8'h9, 8'ha, 8'hb, 8'hc}; endpackage
module m (output logic [7:0] o);
  for (genvar g = 0; g < 1; g++) begin : gb
    logic [7:0] c;
    assign c = q::/*x*/A[g][7:0];
  end
  assign o = gb[0].c;
endmodule
