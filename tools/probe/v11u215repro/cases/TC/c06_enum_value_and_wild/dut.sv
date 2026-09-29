// § enumCloneValueItemKeepsBare215v — one package imports an enum VALUE item, a later one imports the whole package
package p;
  typedef enum logic [1:0] {A, B} e_t;
endpackage
package q;
  import p::B;
  parameter int QV = 1;
endpackage
package r;
  import p::*;
  parameter e_t RP = A;
endpackage
module m;
endmodule
