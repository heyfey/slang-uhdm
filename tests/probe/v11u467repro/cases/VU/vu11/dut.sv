// § unitCopyOwnTsEveryPath467
package a;
  typedef logic [5:0] w_t;
  parameter w_t PW = 6'd9;
endpackage
package c; import a::*; endpackage
import c::*;
module top;
  logic w;
endmodule
