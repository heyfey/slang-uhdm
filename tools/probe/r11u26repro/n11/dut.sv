// n11 — THE COMPILATION-UNIT ($root) TYPEDEF, FLAT WRITES ONLY.  Golden stamps
// the leftovers onto the DESIGN's own copy of the typespec; the drain's walk
// reaches TopPackages' typespecs and TopModules' parameters and never the
// design's list.  Everything here is first-level, so this arm measures the
// FLAT family and must be IDENTICAL pristine and patched.
typedef struct packed { int unsigned a; int unsigned b; } rc_t;

module dut(output logic o);
  function automatic rc_t mk();
    rc_t c; c.a = 3; c.b = 32; return c;
  endfunction
  localparam rc_t L  = mk();
  localparam int  LA = L.a;
  assign o = 1'b0;
endmodule
