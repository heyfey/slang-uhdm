// § unitDynArrTd249
typedef int q_t[$];
module top;
  function automatic int f();
    q_t q;
    q.push_back(3);
    return q.size();
  endfunction
  int x;
  initial x = f();
endmodule
