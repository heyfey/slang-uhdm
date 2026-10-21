// § enumLitArithImportCloneFolds426
package p;
  typedef enum bit [63:0] { A = 0, B = (1<<40), C = 64'd1 << 33 } e_t;
endpackage
package q;
  import p::*;
  e_t v;
endpackage
module top;
  import q::*;
endmodule
