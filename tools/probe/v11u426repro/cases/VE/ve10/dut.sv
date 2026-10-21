// § enumLitArithImportCloneFolds426
package p;
  typedef enum bit signed [15:0] { A = -(1<<3), B = (1<<14) } e_t;
endpackage
package q;
  import p::*;
  e_t v;
endpackage
module top;
  import q::*;
endmodule
