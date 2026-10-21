// § unszPkgFoldElabForm425 (control: 'o17 read genq, no § 425 law fires)
// 'o17 read genq (grid g2/h21)
package p;
  parameter H = 'o17;
endpackage
module top(output logic [7:0] y); for (genvar k=0;k<1;k++) begin : g assign y = p::H; end endmodule
