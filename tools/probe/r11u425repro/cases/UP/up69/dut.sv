// § unszPkgFoldElabForm425 (control: 'b101 read genq, no § 425 law fires)
// 'b101 read genq (grid g2/h45)
package p;
  parameter H = 'b101;
endpackage
module top(output logic [7:0] y); for (genvar k=0;k<1;k++) begin : g assign y = p::H; end endmodule
