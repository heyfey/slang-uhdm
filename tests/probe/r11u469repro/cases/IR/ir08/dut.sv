// § importCopyTsInstByRole469
// the importer declares its own parameter of the imported typedef, and a home localparam
package a;
  typedef logic [3:0] t;
  parameter t PA = 1;
  localparam t LA = 2;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
module top;
  import b::*;
  logic [3:0] w = PB;
endmodule
