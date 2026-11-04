// § multiDeclOneItem140
module top(input int x, output int o);
  function automatic int f(input int v);
    int a = v, b = v + 1;
    return a + b;
  endfunction
  assign o = f(x);
endmodule
