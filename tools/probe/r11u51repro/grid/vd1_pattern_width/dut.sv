// VERIFIER arm (r11v51) — ROAD D, the widths the pass did not cut.  d1 used
// four members that are all `int unsigned` (32) against a literal that is 64,
// so "re-stamp to the member width" and "re-stamp to 32" are indistinguishable.
// Here the members are 8, 16, 64 and 32 bits wide, and there is a package
// `parameter` beside the `localparam` and an UNPACKED-ARRAY pattern.
package pk;
  typedef struct packed {
    logic [7:0]  A;      // narrower than the literal
    logic [15:0] B;
    logic [63:0] C;      // wider than a 32-bit literal
    int unsigned D;      // 32, the d1 shape
  } mix_t;
  localparam mix_t L = '{ A: 64, B: 64, C: 32'd7, D: 64 };
  parameter  mix_t P = '{ A: 5,  B: 5,  C: 5,     D: 5  };   // parameter, not localparam
  typedef logic [7:0] barr_t [2];
  localparam barr_t U = '{ 8'd1, 8'd2 };                     // UNPACKED-array pattern
endpackage
module dut (output logic [63:0] o);
  assign o = pk::L.A | pk::L.B | pk::L.C | pk::L.D |
             pk::P.A | pk::P.B | pk::P.C | pk::P.D |
             pk::U[0] | pk::U[1];
endmodule
