// § namedCallArgFormalTs236 — a named call driving an implicit net, and as a port connection actual
package p;
  typedef int file_t;
  typedef logic [7:0] byte_t;
endpackage
module sub (input int i, output int o);
  assign o = i;
endmodule
module top import p::*; (input int a, input int b, output int o, output int o2);
  function automatic int h(file_t x, byte_t y);
    return x + y;
  endfunction
  assign w = h(.y(b), .x(a));
  assign o = w;
  sub u_s (.i(h(.x(a), .y(b))), .o(o2));
endmodule
