// § tfBodyTypedefForcesBegin304
function automatic int g(int x);
  typedef bit [2:0] s_t;
  return x + 1;
endfunction
module top(input int a, output int o);
  assign o = g(a);
endmodule
