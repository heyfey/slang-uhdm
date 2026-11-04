// § unitCopyOwnTsEveryPath467
package a;
  parameter int PA = 1;
endpackage
package b; import a::*; export a::*; endpackage
package c; import b::*; export b::*; import a::*; endpackage
import c::*;
module top;
  logic w;
endmodule
