// § unitBoundedQTd410
typedef int q_t [$:2];
module top;
  function automatic int f(q_t x);
    return x.size();
  endfunction
  q_t v;
  int n;
  initial n = f(v);
endmodule
