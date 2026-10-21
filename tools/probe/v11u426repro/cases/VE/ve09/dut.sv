// § enumLitArithImportCloneFolds426
package p;
  typedef enum { A = 1 + 2 + 3, B = (10 - 3), C = 2 * (3 + 1) } e_t;
endpackage
package q;
  import p::*;
  function e_t f(); return B; endfunction
endpackage
module top;
  import q::*;
  initial $display(f());
endmodule
