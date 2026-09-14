// m15 — THE ENUM-ELEMENT PATTERN PARAMETER, ALONE.  m9 mixes four RHS kinds
// and golden's evaluation of that body ABORTS partway (see m16); this arm
// carries the enum-valued pattern on its own so the leftover rule can be read
// without the abort.
package pk;
  typedef enum logic [7:0] { E0 = 8'd5, E1 = 8'd6 } e_t;
  typedef struct packed { e_t a; e_t b; } in_t;
  localparam in_t ENP = '{a: E0, b: E1};
  typedef struct packed { in_t n; int unsigned y; } k_t;
  function automatic k_t mk();
    k_t c; c.n = ENP; c.y = 9; return c;
  endfunction
  localparam k_t K = mk();
endpackage

module kid #(
    parameter pk::k_t P = pk::K
) (output logic o);
  localparam pk::in_t RN = P.n;
  assign o = 1'b0;
endmodule

module dut(output logic o);
  kid k0 (.o(o));
endmodule
