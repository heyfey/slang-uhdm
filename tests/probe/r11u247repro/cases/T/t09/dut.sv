// § clsTpKwDefaultArrElemAtUse247
`define QDECL(TY) protected TY queue[$];
class q #(type T=longint);
  `QDECL(T)
  function void push_back(T item); queue.push_back(item); endfunction
  function T pop(); return queue.pop_front(); endfunction
endclass
module top;
  q#(int) x;
  initial x = new();
endmodule
