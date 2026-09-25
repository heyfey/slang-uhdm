// § ppOutputLine166
`define CLAMP(v, m) \
  if (v > m) \
    v = m;
package pk;
  function automatic int f(int x);
    `CLAMP(x, 7)
    return x;
  endfunction
endpackage
module top(input int a, output int y);
  import pk::*;
  assign y = f(a);
endmodule
