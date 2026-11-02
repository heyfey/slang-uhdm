// § unitCopyOwnTsEveryPath467
package a;
  parameter int PA = 1;
endpackage
package b; import a::*; endpackage
package c; import a::*; import b::*; endpackage
package e; import c::*; import a::*; endpackage
import e::*;
import c::*;
module top;
  logic w;
endmodule
