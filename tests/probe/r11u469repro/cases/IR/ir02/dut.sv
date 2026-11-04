// § importCopyTsInstByRole469
// a bit-vector typedef parameter with a sized default, two parameters in the home
package a;
  typedef bit [3:0] nib_t;
  parameter nib_t PA = 4'd3;
  parameter int PI = 7;
endpackage
package b;
  import a::*;
endpackage
module top;
  logic w;
endmodule
