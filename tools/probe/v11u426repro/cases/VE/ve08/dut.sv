// § enumLitArithImportCloneFolds426
package p;
  typedef enum int { A = 0, B = (1<<16) } e_t;
endpackage
package q;
  import p::*;
  e_t v;
endpackage
package r;
  import p::*;
  e_t w;
endpackage
module top;
  import q::*;
  import r::*;
endmodule
