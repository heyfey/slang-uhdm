// g5 — THE PASS-48 FENCES AT THE IMPORT-COPY FACE.  Every parameter is member-
// selected inside its OWN package, in a package FUNCTION body that is never
// called (r11v49's RFDEAD face: the select triggers the reduce without forcing
// constant evaluation, so a type key cannot turn the arm into an error-recovery
// measurement).  Only the fenced SHAPE varies.
package p5;
  typedef struct { int unsigned x; int unsigned y; } inner_t;
  typedef struct { inner_t ip;     int unsigned k; } nest_t;
  typedef struct { int unsigned a; int unsigned b; } plain_t;
  typedef struct { real r;         int unsigned a; } realm_t;
  typedef struct { time t;         int unsigned a; } timem_t;

  localparam plain_t FPLAIN = '{a: 4, b: 8};              // control -> expect FLAT
  localparam nest_t  FNEST  = '{ip: '{x: 2, y: 3}, k: 6}; // pattern-valued element
  localparam plain_t FPOS   = '{4, 8};                    // POSITIONAL
  localparam realm_t FREAL  = '{r: 1.0, a: 4};            // non-integral member
  localparam timem_t FTIME  = '{t: 1, a: 4};              // time member

  function automatic int unsigned pf5();                  // NEVER CALLED
    return FPLAIN.a + FNEST.k + FPOS.a + FREAL.a + FTIME.a;
  endfunction
endpackage

module g5q import p5::*; (input logic clk, output logic [7:0] d);
  assign d = '0;
endmodule

module g5top(input logic clk);
  logic [7:0] dd;
  g5q u_q (.clk(clk), .d(dd));
endmodule
