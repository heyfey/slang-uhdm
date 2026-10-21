// § enumLitArithImportCloneFolds426
package p;
  typedef enum int { A = -(1<<2), B = 7 - 9, C = 0 } e_t;
endpackage
package q;
  import p::*;
  e_t v;
endpackage
module top;
  import q::*;
endmodule
