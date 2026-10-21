// § enumLitArithImportCloneFolds426
package p;
  typedef enum { X = 1<<2, Y = (2+2)*2 } s_e;
endpackage
module top;
  import p::*;
  s_e v;
endmodule
