// § clsImpEnumTdShare452
package a;
  typedef enum {X, Y} st_t;
  st_t g_state;
  int g_int;
endpackage
package c;
  import a::*;
  class B;
    int y;
  endclass
  class D extends B;
    int z;
  endclass
endpackage
module top;
  import c::*;
endmodule
