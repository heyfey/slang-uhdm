// n8 — THE READERS off a nested-assembled base: whole sub-struct, nested,
// bit select, taint (`+1`, `$clog2`), an override actual, a port width, and
// the untainted controls beside them.
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  function automatic c_t mk();
    c_t c; c.u.a = 3; c.u.b = 32; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage

module leaf #(parameter int W = 1) (output logic [W-1:0] o);
  assign o = '0;
endmodule

module kid #(
    parameter pk::c_t CFG = pk::C
) (output logic o);
  localparam pk::in_t SUB  = CFG.u;
  localparam int      DEEP = CFG.u.b;
  localparam int      BIT0 = CFG.d[0];
  localparam int      T1   = CFG.u.b + 1;
  localparam int      T2   = $clog2(T1);
  localparam int      C1   = 5;
  localparam int      C2   = C1 + 1;
  localparam int      C3   = $clog2(C1);
  logic [DEEP-1:0] wide;
  wire [63:0] lo;
  leaf #(.W(DEEP)) u_leaf (.o(lo[DEEP-1:0]));
  assign wide = '0;
  assign o = ^{SUB[0], BIT0[0], T1[0], T2[0], C2[0], C3[0], wide[0], lo[0]};
endmodule

module dut(output logic o);
  kid k0 (.o(o));
endmodule
