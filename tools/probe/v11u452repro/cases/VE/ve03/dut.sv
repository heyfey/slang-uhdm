// § clsImpEnumTdShare452
package u;
  typedef enum {X, Y} st_t;
endpackage
package a;
  import u::*;
  st_t g_state;
endpackage
package b;
  import a::*;
  class C;
    int x;
  endclass
endpackage
module top;
  import b::*;
endmodule
