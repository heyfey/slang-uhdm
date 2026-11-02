// § clsInModEnumLastWriter462
package p;
  typedef enum bit [1:0] { A, B } e_t;
endpackage
interface ifc;
  import p::*;
  class C;
    int k;
  endclass
  e_t e;
endinterface
module top;
  ifc i();
endmodule
