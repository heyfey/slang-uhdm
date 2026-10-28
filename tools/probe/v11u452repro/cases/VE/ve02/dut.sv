// § clsImpEnumTdShare452
package a;
  typedef enum bit [1:0] {X, Y} st_t;
  st_t g_state = Y;
endpackage
package b;
  import a::*;
  class C;
    int x;
  endclass
endpackage
package c2;
  import a::*;
  class D;
    int y;
  endclass
endpackage
module top;
  import b::*;
  import c2::*;
endmodule
