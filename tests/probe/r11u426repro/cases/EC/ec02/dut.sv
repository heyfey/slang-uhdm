// § enumLitArithImportCloneFolds426
package p;
  typedef enum int { A = 2+3, B = 10-3, K3 = 4'h5+4'h3, K4 = 8'h2<<3, K5 = 'h1+'h2, K6 = 3*4 } k_e;
  class C;
    function void f(k_e x); endfunction
  endclass
endpackage
package q;
  import p::*;
  class D extends C;
    k_e k;
  endclass
endpackage
module top;
  import q::*;
  D d;
endmodule
