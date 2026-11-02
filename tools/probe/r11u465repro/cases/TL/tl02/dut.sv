// § pkgTransImpAggTd465
// three hops: e imports c imports b imports a
package a;
  typedef enum {X0, X1} xe;
  typedef struct packed { logic [1:0] f; xe e; } xs;
endpackage
package b;
  import a::*;
endpackage
package c;
  import b::*;
  typedef logic [3:0] cv;
endpackage
package e;
  import c::*;
endpackage
module top;
  import e::*;
endmodule
