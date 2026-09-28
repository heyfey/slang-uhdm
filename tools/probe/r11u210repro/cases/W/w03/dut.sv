// § pkgTopWidePatReplTsName210 — w03: two wide package patterns in two packages, one of them read by the other's function argument (FuncStructValSimple's builder)
package tp;
  typedef struct packed { bit R; logic [3:0][63:0] V; } u_t;
  typedef struct packed { int unsigned W; logic [3:0][63:0] V; } c_t;
endpackage
package ap;
  localparam tp::u_t U1 = '{ R: 1'b0, V: {4{64'h0}} };
endpackage
package bp;
  localparam tp::u_t U2 = '{ R: 1'b1, V: {4{64'h0}} };
  function automatic tp::c_t mk(tp::u_t u);
    tp::c_t c;
    c.V = u.V;
    c.W = 16;
    return c;
  endfunction
endpackage
module dut(output int o);
  parameter tp::c_t P = bp::mk(ap::U1);
  assign o = P.W;
endmodule
