// § clsImpEnumTdShare452
package a;
  typedef enum {X, Y} st_t;
  st_t g_state;
endpackage
package b;
  import a::*;
  class C;
    int x;
  endclass
endpackage
package c;
  import a::*;
  import b::*;
  class D extends C;
    int y;
  endclass
endpackage
module top;
  import c::*;
endmodule
