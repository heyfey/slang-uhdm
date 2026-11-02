// § unitCopyOwnTsEveryPath467
package a;
  typedef enum logic [1:0] {E0, E1, E2} e_t;
  parameter e_t PE = E1;
  parameter int PI = 3;
endpackage
package b; import a::*; endpackage
package c; import a::*; import b::*; endpackage
import c::*;
module top;
  logic w;
endmodule
