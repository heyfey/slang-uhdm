// § enumLitArithImportCloneFolds426
package p;
  typedef enum logic [2:0] { A = 3'd1 << 1, B = 1 + 1 + 1 + 1 } e_t;
endpackage
package q;
  import p::*;
  e_t v;
endpackage
module top(output logic [2:0] o);
  import q::*;
  import p::*;
  assign o = B;
endmodule
