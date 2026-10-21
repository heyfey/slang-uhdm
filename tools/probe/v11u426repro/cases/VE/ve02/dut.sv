// § enumLitArithImportCloneFolds426
package p;
  typedef enum bit [31:0] { A = 0, B = (1<<31) } e_t;
endpackage
package q;
  import p::*;
  e_t v;
endpackage
module top;
  import q::*;
endmodule
