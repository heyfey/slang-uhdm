// § emptyConcatArrayVar413
typedef int q_t[$];
module top;
  q_t q;
  function automatic q_t clr();
    return {};
  endfunction
  initial q = clr();
endmodule
