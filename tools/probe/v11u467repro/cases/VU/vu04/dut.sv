// § unitCopyOwnTsEveryPath467
package a;
  parameter int PA = 1;
endpackage
package b; import a::*; endpackage
package d; import a::*; import b::*; endpackage
package c; import d::*; import b::*; import a::*; endpackage
import c::*;
import d::*;
module top;
  logic w;
endmodule
