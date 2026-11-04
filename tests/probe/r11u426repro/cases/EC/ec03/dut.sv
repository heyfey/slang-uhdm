// § enumLitArithImportCloneFolds426
package p;
  typedef bit [31:0] flag_t;
  typedef enum flag_t { DEF = 'h0, DEEP = (1<<16), SHALLOW = (1<<17), REF = (1<<18) } pol_e;
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
