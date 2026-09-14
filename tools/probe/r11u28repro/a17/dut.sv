// a17 — THE REFERENCE OPERAND KIND, alone.  The pattern parameter's elements
// are PARAMETER REFERENCES (`'{a: RA, b: RB}`).  Surelog's elaborated listing
// folds them to constants, so the split should render them like literals —
// but the arm carries its OWN pre-existing head (the reference element's
// `int_typespec` ref, r11u26 R1's neighbourhood), so read the CELL census
// beside the head count here.
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  localparam int unsigned RA = 11;
  localparam int unsigned RB = 22;
  localparam in_t REF = '{a: RA, b: RB};
  typedef struct packed { in_t v; int unsigned w; } mid_t;      // 96
  typedef struct packed { mid_t u; int unsigned d; } c_t;
  function automatic c_t mk();
    c_t c; c.u.w = 7; c.u.v = REF; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage

module kid #(
    parameter pk::c_t P = pk::C
) (output logic o);
  localparam pk::mid_t S1 = P.u;
  assign o = 1'b0;
endmodule

module dut(output logic o);
  kid k0 (.o(o));
endmodule
