// § procAsgRhsPkgFoldTs471
// signed narrow parameter assigned to a wider variable (downstream sign extension)
package a;
  parameter logic signed [3:0] PS = -4'sd3;
endpackage
module top(input logic clk, output logic signed [7:0] y, output logic signed [7:0] z);
  import a::*;
  always_comb y = PS;
  always_ff @(posedge clk) z <= PS;
endmodule
