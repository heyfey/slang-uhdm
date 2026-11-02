// § enumSharedCloneHomeInst471
// a diamond d <- b, c <- a with a module reading the parameter through d
package a;
  typedef enum logic [1:0] {E0, E1, E2} e_t;
  parameter e_t PE = E1;
endpackage
package b;
  import a::*;
endpackage
package c;
  import a::*;
endpackage
package d;
  import b::*;
  import c::*;
endpackage
module top(output logic [1:0] y);
  import a::*;
  import d::*;
  assign y = PE;
endmodule
