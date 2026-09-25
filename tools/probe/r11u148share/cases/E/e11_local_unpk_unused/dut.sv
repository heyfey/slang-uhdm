module top(output int o);
  function automatic int f(input int a);
    int t [2];
    return a + 1;
  endfunction
  assign o = f(3);
endmodule
