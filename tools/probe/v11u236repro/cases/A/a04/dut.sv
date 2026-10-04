// § namedCallArgFormalTs236 — named calls in a for-generate and an if-generate, and in an interface body
package p;
  typedef int file_t;
  typedef logic [7:0] byte_t;
endpackage
interface ifc import p::*; (input int a);
  function automatic int h(file_t x, byte_t y);
    return x + y;
  endfunction
  int v;
  assign v = h(.y(a), .x(a));
endinterface
module top import p::*; (input int a, output int o, output int o2[2]);
  function automatic int g(file_t x, byte_t y);
    return x ^ y;
  endfunction
  ifc u_i (.a(a));
  assign o = u_i.v;
  for (genvar i = 0; i < 2; i++) begin : gl
    assign o2[i] = g(.y(i), .x(a));
  end
endmodule
