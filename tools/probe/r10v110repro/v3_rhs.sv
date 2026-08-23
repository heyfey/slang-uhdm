// r10v110 arm v3 — RHS-SPELLING axis for the dotted dyn-array `new`.
// Sizes: parameter, localparam, function call, arithmetic, $bits/$size,
// ternary, cast, enum, and the COPY form with dotted / this. / call sources.
// Plus every non-`new[]` RHS as a control in the SAME dotted shape.
package Rr3;
  parameter int PWIDE3 = 5;
  class Kk3;
    int   av[];
    byte  bv[];
    Kk3   nx3;
    int   sc3;
    function int sz3(); return 3; endfunction
  endclass
  typedef enum int { E3A = 2, E3B = 6 } e3_t;
endpackage

module v3top;
  import Rr3::*;
  localparam int LP3 = 4;
  parameter  int PR3 = 7;
  logic clk3;
  Kk3 hh3;
  int q3[];
  int n3v;
  e3_t ee3;

  initial begin
    hh3 = new(); hh3.nx3 = new(); n3v = 2; q3 = new [3]; ee3 = E3A;

    hh3.av = new [PR3];              // v3d01 size = module parameter    (in law)
    hh3.bv = new [LP3];              // v3d02 size = localparam          (in law)
    hh3.av = new [PWIDE3];           // v3d03 size = package parameter   (in law)
    hh3.bv = new [hh3.sz3()];        // v3d04 size = METHOD call         (in law)
    hh3.av = new [n3v + 1];          // v3d05 size = expression          (in law)
    hh3.bv = new [$size(q3)];        // v3d06 size = $size               (in law)
    hh3.av = new [$bits(int)];       // v3d07 size = $bits               (in law)
    hh3.bv = new [(n3v > 0) ? 2 : 3];// v3d08 size = ternary             (in law)
    hh3.av = new [int'(2.0)];        // v3d09 size = cast                (in law)
    hh3.bv = new [ee3];              // v3d10 size = enum value          (in law)

    hh3.av = new [4] (q3);           // v3d11 copy from a local array    (in law)
    hh3.av = new [4] (hh3.av);       // v3d12 copy from ITSELF (dotted)  (in law)
    hh3.bv = new [4] (hh3.bv);       // v3d13 copy, byte                 (in law)

    // --- controls: the SAME dotted lvalue, a NON-new RHS
    hh3.nx3 = new ();                // v3d14 class new, parens          (control)
    hh3.nx3 = new;                   // v3d15 class new, BARE            (control)
    hh3.sc3 = 5;                     // v3d16 literal                    (control)
    hh3.sc3 = n3v * 2;               // v3d17 expression                 (control)
    hh3.sc3 = hh3.sz3();             // v3d18 method call                (control)
    hh3.sc3 <= 6;                    // v3d19 nonblocking                (control)
    hh3.sc3 += 1;                    // v3d20 compound +=                (control)
    hh3.sc3 -= 1;                    // v3d21 compound -=                (control)
    #1 hh3.sc3 = 2;                  // v3d22 delayed                    (control)
    @(posedge clk3) hh3.sc3 = 3;     // v3d23 event-controlled           (control)
    hh3.av = q3;                     // v3d24 whole-array copy, no new   (control)
    hh3.av = '{1, 2};                // v3d25 assignment pattern         (control)
    {hh3.sc3, n3v} = 8'hAB;          // v3d26 concat lvalue              (control)
  end
endmodule
