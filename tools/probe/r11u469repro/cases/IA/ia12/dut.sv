// § importCopyTsInstByRole469
// a localparam of the home with a typedef type and a parameter defined from it
package a;
  typedef logic [7:0] t;
  localparam t LA = 8'hff;
  parameter t PA = LA;
endpackage
package b;
  import a::*;
endpackage
module top;
  import a::*;
  logic [7:0] w = PA;
endmodule
