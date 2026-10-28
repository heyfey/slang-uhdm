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
module top;
  import b::*;
endmodule
