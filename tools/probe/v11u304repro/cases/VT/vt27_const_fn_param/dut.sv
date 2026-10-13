// § tfBodyTypedefForcesBegin304
module top;
  function automatic int f(int a);
    typedef logic [3:0] n_t;
    return n_t'(a) + 1;
  endfunction
  localparam int K = f(20);
  logic [K-1:0] w;
endmodule
