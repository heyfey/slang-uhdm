// § enumCloneValueItemKeepsBare215v — a package importing an enum VALUE by explicit item and using it in a parameter
package p;
  typedef enum logic [1:0] {A, B} e_t;
endpackage
package q;
  import p::B;
  parameter p::e_t QP = B;
endpackage
module m;
endmodule
