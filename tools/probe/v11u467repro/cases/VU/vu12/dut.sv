// § unitCopyOwnTsEveryPath467
package a;
  parameter int PA = 1;
endpackage
package b; import a::*; endpackage
package c; import a::*; import b::*; endpackage
module top;
  logic w;
endmodule
import c::*;
module top2;
  logic v;
endmodule
