// § pkgImpParamsAheadOfOwn453
package a;
  parameter int PA = 1;
endpackage
package a2;
  parameter int PA2 = 4;
endpackage
package b;
  parameter int PB = 2;
  import a::*;
  parameter int PC = 3;
  import a2::*;
endpackage
package c;
  import b::*;
endpackage
module top;
  import c::*;
endmodule
