// § namedCallArgFormalTs236 — named call in a net declaration assignment and with an operation and a concatenation actual
package p;
  typedef int file_t;
  typedef logic [7:0] byte_t;
endpackage
module top import p::*; (input int a, input logic [3:0] b, output int o, output int o2);
  function automatic int h(file_t x, byte_t y);
    return x - y;
  endfunction
  wire [31:0] w = h(.y({b, b}), .x(a + 1));
  assign o = w;
  assign o2 = h(.x(a), .y(b[1:0]));
endmodule
