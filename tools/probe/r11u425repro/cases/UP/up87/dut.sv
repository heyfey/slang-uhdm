// § unszPkgFoldElabForm425 (control: 'd3000000000 read port, no § 425 law fires)
// 'd3000000000 read port (grid g2/h63)
package p;
  parameter H = 'd3000000000;
endpackage
module sub(input logic [7:0] i, output logic [7:0] o); assign o = i; endmodule
module top(output logic [7:0] y); sub u(.i(p::H), .o(y)); endmodule
