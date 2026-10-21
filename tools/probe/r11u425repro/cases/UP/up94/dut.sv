// § unszPkgFoldElabForm425 (control: 'd3000000000 read sub, no § 425 law fires)
// 'd3000000000 read sub (grid g2/h70)
package p;
  parameter H = 'd3000000000;
endpackage
module sub(output logic [7:0] y); import p::*; wire [7:0] w = H; assign y = p::H + w; endmodule
module top(output logic [7:0] y); sub u(.y(y)); endmodule
