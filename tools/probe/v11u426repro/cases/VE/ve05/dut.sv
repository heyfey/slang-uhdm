// § enumLitArithImportCloneFolds426
package p;
  typedef enum int { A = 0, B = (1<<16) } e_t;
endpackage
package q;
  import p::*;
  export p::*;
  e_t v;
endpackage
module top;
  import q::*;
  e_t w;
endmodule
