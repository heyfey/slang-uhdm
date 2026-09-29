package p;
  typedef enum logic [1:0] {A, B} e_t;
  typedef e_t alias_t;
  function automatic void f(alias_t v); endfunction
endpackage
module m;
endmodule
