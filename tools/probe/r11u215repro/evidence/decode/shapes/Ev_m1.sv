package p;
  typedef enum logic [1:0] {A, B} e_t;
  typedef e_t alias_t;
  class c;
    alias_t m;
  endclass
endpackage
module m;
  import p::*;
endmodule
