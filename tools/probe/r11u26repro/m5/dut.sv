// m5 — THE READERS of a member whose leftover is an OPERATION, beside the
// landed slice laws.  `C.u` (whole), `C.u.a` / `C.u.b` (nested slices),
// `C.u[3]` (a bit select), `C.u.a + 1` (taint), an override actual and a port
// width.  The untainted control `C.d` reads a plain constant leftover.
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage

module kid #(
    parameter pk::c_t P = pk::C,
    parameter int unsigned W = 8
) (output logic [W-1:0] o);
  localparam pk::in_t  S  = P.u;
  localparam int unsigned A = P.u.a;
  localparam int unsigned B = P.u.b;
  localparam logic     BIT = P.u[3];
  localparam int unsigned T = P.u.b + 1;
  localparam int unsigned D = P.d;
  assign o = '0;
endmodule

module dut(output logic [21:0] o);
  kid #(.W(pk::C.u.b)) k0 (.o(o));
endmodule
