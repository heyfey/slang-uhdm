// § clsImpEnumTdShare452
package a;
  typedef enum logic [1:0] {X = 2'b01, Y = 2'b10} st_t;
  st_t g_state;
endpackage
package b;
  import a::*;
  class C;
    st_t own;
  endclass
endpackage
module top;
  import b::*;
endmodule
