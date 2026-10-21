// § unszPkgFoldElabForm425 (control: 'h1F read port, no § 425 law fires)
// 'h1F read port (grid g2/h27)
package p;
  parameter H = 'h1F;
endpackage
module sub(input logic [7:0] i, output logic [7:0] o); assign o = i; endmodule
module top(output logic [7:0] y); sub u(.i(p::H), .o(y)); endmodule
