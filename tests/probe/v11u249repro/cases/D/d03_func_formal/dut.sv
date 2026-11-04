// § unitDynArrTd249
typedef int q_t[$];
module top;
  function automatic int f(q_t a); return a.size(); endfunction
  int r; q_t z;
  initial r = f(z);
endmodule
