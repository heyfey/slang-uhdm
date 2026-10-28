// § pkgImpParamsAheadOfOwn453
package a;
  parameter int PA = 1;
endpackage
package b;
  typedef int t_t;
  parameter t_t PB = 2;
  import a::*;
endpackage
package c;
  parameter int PC0 = 0;
  import b::*;
endpackage
module top;
  import c::*;
endmodule
