package p;
  typedef enum logic [1:0] {A, B} e_t;
  typedef e_t alias_t;

endpackage
program pg;
  import p::*;
endprogram
module m;
endmodule
