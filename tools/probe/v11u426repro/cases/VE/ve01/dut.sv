// § enumLitArithImportCloneFolds426
package p;
  typedef enum logic [7:0] { A = (1<<3), B, C = 2*3 } e_t;
endpackage
package q;
  import p::*;
  e_t v;
endpackage
module top;
  import q::*;
endmodule
