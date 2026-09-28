// § tfItemInitLocalAtType209: a module function without parentheses, an input declared in the body
module top;
  function int g;
    input int a;
    int t = 1;
    logic [3:0] v = 4'd2;
    int u;
    u = a + t + v;
    return u;
  endfunction
  int r;
  initial r = g(3);
endmodule
