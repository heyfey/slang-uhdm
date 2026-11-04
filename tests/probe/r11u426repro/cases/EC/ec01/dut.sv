// § enumLitArithImportCloneFolds426
package p;
  typedef enum int { DEF = 0, DEEP = (1<<16), SHALLOW = (1<<17) } pol_e;
  class C;
    function void f(pol_e x); endfunction
  endclass
endpackage
package q;
  import p::*;
  class D extends C;
    pol_e k;
  endclass
endpackage
module top;
  import q::*;
  D d;
endmodule
