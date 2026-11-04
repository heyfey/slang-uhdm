// § enumSharedCloneHomeInst471
// three importing packages, two enum parameters
package a;
  typedef enum logic [1:0] {E0, E1, E2} e_t;
  parameter e_t PE = E1;
  localparam e_t LE = E2;
endpackage
package b;
  import a::*;
endpackage
package c;
  import a::*;
endpackage
package d;
  import a::*;
endpackage
module top;
  logic w;
endmodule
