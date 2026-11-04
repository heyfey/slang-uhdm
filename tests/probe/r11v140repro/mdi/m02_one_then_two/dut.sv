// § multiDeclOneItem140
module top(input int x, output int o);
  function automatic int f(input int v);
    int a;
    int b, c;
    a = v; b = a; c = b;
    return c;
  endfunction
  assign o = f(x);
endmodule
