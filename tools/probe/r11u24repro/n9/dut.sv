// n9 — SHAPES BESIDE THE DOTTED CHAIN.  `c_t` writes a packed UNION member
// nested (`c.n.x = 9`) and is a POSITIVE arm; `d_t` writes a packed-array
// ELEMENT (`c.arr[0] = 8'h5`) and is the measured DECLINE — the indexed write
// reaches the same producer arm but its bit range needs the packed-array
// layout rule, which is a different law.
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef union  packed { int unsigned x; int unsigned y; } un_t;
  typedef struct packed { in_t u; un_t n; int unsigned d; } c_t;
  typedef struct packed { in_t u; logic [1:0][7:0] arr; int unsigned d; } d_t;
  function automatic c_t mkU();
    c_t c;
    c.u.a = 3; c.u.b = 32;
    c.n.x = 9;
    c.d = 64;
    return c;
  endfunction
  function automatic d_t mkA();
    d_t c;
    c.u.a = 3; c.u.b = 32;
    c.arr[0] = 8'h5;
    c.arr[1] = 8'h6;
    c.d = 64;
    return c;
  endfunction
  localparam c_t CU = mkU();
  localparam d_t CA = mkA();
endpackage

module kid #(
    parameter pk::c_t P1 = pk::CU,
    parameter pk::d_t P2 = pk::CA
) (output logic o);
  localparam pk::in_t S1 = P1.u;
  localparam int      N1 = P1.n.x;
  localparam pk::in_t S2 = P2.u;
  assign o = ^{S1[0], N1[0], S2[0]};
endmodule

module dut(output logic o);
  kid k0 (.o(o));
endmodule
