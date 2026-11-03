// § modImpCopyTdChainHomeTop473
// packed struct typedef
package a;
  typedef struct packed { logic [1:0] x; logic [1:0] z; } t;
endpackage
package b;
  import a::*;
  parameter t PB = 4'b1001;
endpackage
module top(output logic [3:0] y);
  import b::*;
  assign y = PB;
endmodule
