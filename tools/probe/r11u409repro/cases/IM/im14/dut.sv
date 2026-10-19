// § modImpTdParamTsClone409
module top;
  typedef bit [3:0] ft_t;
  function automatic int f();
    parameter ft_t A = 4'd5;
    return A;
  endfunction
  int x;
  initial x = f();
endmodule
