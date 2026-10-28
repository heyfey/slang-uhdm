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
  class D;
    int y;
  endclass
endpackage
module top;
  import b::*;
  import c::*;
endmodule
