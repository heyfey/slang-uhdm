// § multiDeclOneItem140
module top(input int x, output int o);
  function automatic int f(input int v);
    int a, b;
    return v;
  endfunction
  assign o = f(x);
endmodule
