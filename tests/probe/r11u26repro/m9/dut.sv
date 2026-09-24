// m9 — THE OTHER NON-CONSTANT RHS KINDS beside the pattern, all FIRST-LEVEL:
// (the builder's local is `x`: naming it `c` beside a member also named `c`
//  makes the producer's path decode resolve EVERY write to that one member —
//  a real behaviour, but not the one this arm is for.)
// a CONCAT parameter, a REPLICATION parameter, an unfoldable enum-ref pattern,
// and a plain arithmetic parameter (which DOES fold to a constant — the
// control that says the law only fires where the Rhs is not a constant).
package pk;
  typedef enum logic [7:0] { E0 = 8'd5, E1 = 8'd6 } e_t;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  localparam in_t CAT = {32'd3, 32'd4};
  localparam logic [63:0] REP = {2{32'hAB}};
  localparam in_t ENP = '{a: E0, b: E1};
  localparam int unsigned ARI = 3 + 4;
  typedef struct packed {
    in_t c;              // <- CAT
    logic [63:0] r;      // <- REP
    in_t n;              // <- ENP
    int unsigned y;      // <- ARI
  } k_t;
  function automatic k_t mk();
    k_t x; x.c = CAT; x.r = REP; x.n = ENP; x.y = ARI; return x;
  endfunction
  localparam k_t K = mk();
endpackage

module kid #(
    parameter pk::k_t P = pk::K
) (output logic o);
  localparam pk::in_t RC = P.c;
  localparam pk::in_t RN = P.n;
  assign o = 1'b0;
endmodule

module dut(output logic o);
  kid k0 (.o(o));
endmodule
