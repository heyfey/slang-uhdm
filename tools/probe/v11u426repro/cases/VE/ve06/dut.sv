// § enumLitArithImportCloneFolds426
package p;
  typedef enum int { A = 2, B = A << 1, C = (1<<4) } e_t;
endpackage
package q;
  import p::*;
  e_t v;
endpackage
module top;
  import q::*;
endmodule
