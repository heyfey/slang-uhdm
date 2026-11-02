// § importCopyTsInstByRole469
// a module reads the home parameter qualified and also imports the importer (downstream)
package a;
  typedef logic [3:0] t;
  parameter t PA = 4'd6;
endpackage
package b;
  import a::*;
  localparam t LB = PA + 4'd1;
  export *::*;
endpackage
module top(output logic [3:0] y, output logic [3:0] z);
  import b::*;
  assign y = a::PA;
  assign z = LB;
endmodule
