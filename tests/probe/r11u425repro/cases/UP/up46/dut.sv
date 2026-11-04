// § unszPkgFoldElabForm425 (with § unszPkgFoldNdaNoTs425)
// 'o17 read sub (grid g2/h22)
package p;
  parameter H = 'o17;
endpackage
module sub(output logic [7:0] y); import p::*; wire [7:0] w = H; assign y = p::H + w; endmodule
module top(output logic [7:0] y); sub u(.y(y)); endmodule
