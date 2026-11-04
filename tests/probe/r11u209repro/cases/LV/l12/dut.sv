// § tfItemInitLocalAtType209: locals declared inside a macro body
`define DECL(n, v) int n = v;
module top;
  function int mf;
    `DECL(a, 1)
    int b = 2;
    return a + b;
  endfunction
  int r;
  initial r = mf();
endmodule
