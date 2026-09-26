// § castUnionCloneFile171
package pu;
`include "u.svh"
  function automatic logic [3:0] g(logic [7:0] x);
    u_t t;
    t = u_t'(x);
    return t.f.a;
  endfunction
endpackage
module m1 import pu::*; (input logic [7:0] i, output logic [3:0] o);
  u_t x;
  assign x = u_t'(i);
  assign o = x.f.b;
endmodule
module dut import pu::*; (input logic [7:0] i, output logic [3:0] o, p, q);
  m1 u(i, o);
  u_t y;
  assign y = u_t'(i);
  assign p = y.f.a;
  assign q = g(i);
endmodule
