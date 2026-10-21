// § unszPkgFoldElabForm425
// 'd0 read port (grid g2/h51)
package p;
  parameter H = 'd0;
endpackage
module sub(input logic [7:0] i, output logic [7:0] o); assign o = i; endmodule
module top(output logic [7:0] y); sub u(.i(p::H), .o(y)); endmodule
