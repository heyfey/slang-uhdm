// § paramBoundQTd442
module top;
  parameter int P = 3;
  typedef int q_t [$:P];
  q_t a, b;
  function automatic int f();
    q_t loc;
    return loc.size();
  endfunction
endmodule
