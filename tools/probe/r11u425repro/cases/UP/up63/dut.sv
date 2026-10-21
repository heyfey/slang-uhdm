// § unszPkgFoldElabForm425 (control: 'b101 read port, no § 425 law fires)
// 'b101 read port (grid g2/h39)
package p;
  parameter H = 'b101;
endpackage
module sub(input logic [7:0] i, output logic [7:0] o); assign o = i; endmodule
module top(output logic [7:0] y); sub u(.i(p::H), .o(y)); endmodule
