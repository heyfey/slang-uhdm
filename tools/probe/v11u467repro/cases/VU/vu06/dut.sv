// § unitCopyOwnTsEveryPath467
package a;
  parameter int PA = 1;
endpackage
package b; import a::*; endpackage
package c; import a::*; import b::*;
  parameter int PA = 9;
endpackage
import c::*;
module top;
  logic w;
endmodule
