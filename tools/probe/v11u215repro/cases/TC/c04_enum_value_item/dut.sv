// § enumCloneValueItemKeepsBare215v — a package importing only an enum VALUE by explicit item (import p::B): its clone listing
package p;
  typedef enum logic [1:0] {A, B} e_t;
endpackage
package q;
  import p::B;
  parameter int QV = 1;
endpackage
module m;
endmodule
