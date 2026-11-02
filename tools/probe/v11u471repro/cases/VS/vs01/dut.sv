// § enumSharedCloneHomeInst471
// enum parameter declared in b over a's enum; two importers of b
package a;
  typedef enum logic [1:0] {X0, X1, X2} e_t;
endpackage
package b;
  import a::*;
  parameter e_t PB = X1;
endpackage
package c;
  import b::*;
endpackage
package d;
  import b::*;
endpackage
module top(output logic [1:0] y);
  import d::*;
  assign y = 2'd0;
endmodule
