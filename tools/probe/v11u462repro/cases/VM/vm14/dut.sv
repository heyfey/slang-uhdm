// § clsInModTdLastWriter462
package p;
  typedef struct { int a; logic [3:0] b; } s_t;
endpackage
interface ifc;
  import p::*;
  class C;
    s_t f;
  endclass
  s_t v;
endinterface
module top;
  ifc i();
endmodule
