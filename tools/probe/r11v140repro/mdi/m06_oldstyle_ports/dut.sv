// § multiDeclOneItem140
module top(input int x, output int o);
  function automatic int f;
    input int v, w;
    int a, b;
    a = v; b = w;
    f = a + b;
  endfunction
  assign o = f(x, x);
endmodule
