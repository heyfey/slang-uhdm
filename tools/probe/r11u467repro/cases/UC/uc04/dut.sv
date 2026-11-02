// § unitCopyOwnTsEveryPath467
package a;
  parameter int PA = 1;
  parameter PU = 3;
endpackage
package b;
  import a::*;
endpackage
package c;
  import b::*;
  import a::*;
endpackage
import c::*;
module top;
  logic w;
endmodule
