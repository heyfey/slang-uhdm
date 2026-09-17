// v11u59 xv6 — THE EXACT-POWER BOUNDARY.  A masked value of exactly 2**w reads
// 0, and 2**w - 1 reads unchanged.  Cut both at three widths so the "fits" and
// "over-wide by exactly one" cells sit side by side: 255/256 into 8, 15/16 into
// 4, 1/2 into 1.  The FITS cells must be byte-identical under both binaries
// (the removal is the identity there) and the OVER cells must move to golden.
package pk;
  localparam int unsigned F8 = 255;
  localparam int unsigned O8 = 256;
  localparam int unsigned F4 = 15;
  localparam int unsigned O4 = 16;
  localparam int unsigned F1 = 1;
  localparam int unsigned O1 = 2;
  typedef struct packed {
    logic [7:0]   E8;  // F8 fits exactly
    logic [7:0]   G8;  // O8 over by one bit -> masked reads 0
    logic [3:0]   E4;  // F4 fits exactly
    logic [3:0]   G4;  // O4 -> masked reads 0
    logic         E1;  // F1 fits exactly
    logic         G1;  // O1 -> masked reads 0
    logic [127:0] W;
    int unsigned  Z;
  } u_t;
  typedef struct packed { int unsigned X; logic G; } r_t;
  function automatic r_t build(u_t c);
    r_t r;
    r.X = {c.E8, c.G8, c.E4, c.G4, c.E1, c.G1};
    r.G = (c.Z > 0);
    return r;
  endfunction
  localparam u_t BASE = '{ E8: F8, G8: O8, E4: F4, G4: O4, E1: F1, G1: O1,
                           W: 128'(0), Z: unsigned'(64) };
endpackage
module dut #(parameter pk::r_t R = pk::build(pk::BASE)) (output logic [31:0] o);
  assign o = R.X;
endmodule
