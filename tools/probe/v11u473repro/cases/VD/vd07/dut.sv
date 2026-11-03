// § modImpCopyTdChainHomeTop473
// localparam in module from PB and replication
package a;
  typedef logic [3:0] t;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
module top(output logic [7:0] y);
  import b::*;
  localparam int L = PB * 2;
  assign y = {2{PB}} ^ L;
endmodule
