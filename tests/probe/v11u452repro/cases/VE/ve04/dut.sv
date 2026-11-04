// § clsImpEnumTdShare452
package a;
  enum {X, Y} g_anon;
  typedef enum {P, Q} st_t;
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
