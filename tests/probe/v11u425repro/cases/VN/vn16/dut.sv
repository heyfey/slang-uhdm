// § unszPkgFoldNdaNoTs425
package p;
  parameter H = 'd200;
  parameter O = 'o17;
  parameter Z = 'd0;
  parameter BIG = 'd3000000000;
endpackage
module top(output logic [7:0] y);
  import p::*;
  wire logic [7:0] w = H;
  uwire [7:0] v = O;
  assign y = w ^ v;
endmodule
