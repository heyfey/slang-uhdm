// § clsImpEnumTdShare452
package a;
  typedef enum {X, Y, Z} st_t;
  st_t g_state = Y;
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
