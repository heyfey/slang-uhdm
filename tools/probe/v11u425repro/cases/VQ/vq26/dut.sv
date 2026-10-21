// § unszPkgFoldElabForm425
package p;
  parameter H = 'd200;
  parameter O = 'o17;
  parameter Z = 'd0;
  parameter BIG = 'd3000000000;
endpackage
module top(output int y [2]);
  int arr [2] = '{p::H, p::O};
  assign y = arr;
endmodule
