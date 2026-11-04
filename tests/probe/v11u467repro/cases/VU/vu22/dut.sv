// § unitCopyOwnTsEveryPath467
package a;
  parameter int PA = 1;
endpackage
package b; import a::*; endpackage
package c; import a::*; import b::*; endpackage
package d; import a::*; import b::*; import c::*; endpackage
import d::*;
module top;
  logic w;
endmodule
