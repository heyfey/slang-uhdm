// § unszPkgFoldElabForm425 (control: 'd3000000000 read genq, no § 425 law fires)
// 'd3000000000 read genq (grid g2/h69)
package p;
  parameter H = 'd3000000000;
endpackage
module top(output logic [7:0] y); for (genvar k=0;k<1;k++) begin : g assign y = p::H; end endmodule
