// § aliasElemDynTd406
typedef logic [3:0] n_t;
typedef n_t q_t [$];
module top;
  q_t q;
  function automatic int f(q_t a);
    return a.size();
  endfunction
  int x;
  initial x = f(q);
endmodule
