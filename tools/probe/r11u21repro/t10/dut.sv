// t10 — the LHS side: an UNTYPED localparam, an `int unsigned` LHS reading a
// SIGNED int member (the adjustSize branch that MUTATES the member typespec),
// a generate-scope localparam, and a genvar-free gen block.
package pk;
  typedef struct packed {
    int unsigned a;
    int          sgn;     // SIGNED member
    logic [7:0]  l8;
  } c_t;
  function automatic c_t mk();
    c_t c; c.a = 3; c.sgn = -5; c.l8 = 8'hA5; return c;
  endfunction
  localparam c_t C = mk();
endpackage

module dut #(
    parameter pk::c_t CFG = pk::C
) (output logic o);
  localparam          UNT  = CFG.a;      // UNTYPED localparam
  localparam int unsigned UU = CFG.sgn;  // unsigned LHS <- SIGNED int member
  localparam int      SS   = CFG.sgn;    // signed   LHS <- SIGNED int member
  localparam int      L8   = CFG.l8;
  if (1) begin : g
    localparam int GA = CFG.a;           // inside a generate scope
  end
  assign o = ^{UNT[0], UU[0], SS[0], L8[0], g.GA[0]};
endmodule
