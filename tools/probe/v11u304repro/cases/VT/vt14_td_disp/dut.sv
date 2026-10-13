// § tfBodyTypedefForcesBegin304
module top;
  function automatic void f(int a);
    typedef logic [1:0] n_t;
    $display("%0d", n_t'(a));
  endfunction
  initial f(3);
endmodule
