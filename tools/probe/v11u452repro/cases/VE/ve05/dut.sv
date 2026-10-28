// § clsImpEnumTdShare452
package a;
  typedef enum {X, Y} st_t;
  st_t g_state;
endpackage
package b;
  import a::*;
  class C;
    int x;
    st_t own;
  endclass
endpackage
module top;
  import b::*;
  C c;
  initial begin
    c = new;
    c.own = c.own;
  end
endmodule
