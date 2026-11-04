// § unitCopyOwnTsEveryPath467
package a;
  typedef logic [2:0] t3_t;
  parameter t3_t PT = 3'd5;
  parameter int PI = 4;
endpackage
package b; import a::*; endpackage
package c; import a::*; import b::*; endpackage
import a::*;
import c::*;
module top;
  logic w;
endmodule
