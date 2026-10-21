// § unszPkgFoldElabForm425 (control: 'h1F read genq, no § 425 law fires)
// 'h1F read genq (grid g2/h33)
package p;
  parameter H = 'h1F;
endpackage
module top(output logic [7:0] y); for (genvar k=0;k<1;k++) begin : g assign y = p::H; end endmodule
