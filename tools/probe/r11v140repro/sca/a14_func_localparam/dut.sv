// § sysArgUnaryWholeSpan140
module top(input logic [7:0] a, output int o);
  function automatic int f();
    int r;
    r = $bits(~a);
    return r;
  endfunction
  assign o = f();
endmodule
