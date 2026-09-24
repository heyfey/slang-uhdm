// § multiDeclOneItem140
module top(input int x, output int o);
  function automatic int f(input int v);
    int a[2], b;
    a[0] = v; b = a[0];
    return b;
  endfunction
  assign o = f(x);
endmodule
