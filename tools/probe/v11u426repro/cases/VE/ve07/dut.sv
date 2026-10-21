// § enumLitArithImportCloneFolds426
package p;
  typedef enum logic [15:0] { A = 'h1 << 4, B = 4'h1 << 2, C = 16'hff >> 2 } e_t;
endpackage
package q;
  import p::*;
  e_t v;
endpackage
module top;
  import q::*;
endmodule
