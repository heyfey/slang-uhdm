// § unszPkgFoldElabForm425
// 'd200 read genq (grid g2/h09)
package p;
  parameter H = 'd200;
endpackage
module top(output logic [7:0] y); for (genvar k=0;k<1;k++) begin : g assign y = p::H; end endmodule
