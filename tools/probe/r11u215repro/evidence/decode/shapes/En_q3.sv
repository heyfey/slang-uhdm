package p;
  typedef enum logic [1:0] {A, B} e_t;
  typedef e_t alias_t;

endpackage
package q;
  import p::*;
  class d; int z; endclass
endpackage
module m;
endmodule
