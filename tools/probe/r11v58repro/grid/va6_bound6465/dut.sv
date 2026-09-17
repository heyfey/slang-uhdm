// v11u58 va6 — THE BAIL BOUNDARY, 64 AGAINST 65.  `shift = csize - 1 - i` with
// i == 0 returns when csize >= 65, so a 64-bit member must NOT end the walk and
// a 65-bit member must.  The patch writes `if (w58 > 64) break;`.
// PREDICT: A 32, S64 64, B 32, S65 65 (stamped, then the walk returns),
// C UNSTAMPED at its compiled 64.
package pk;
  typedef struct packed {
    int unsigned A;    // 64            -> 32
    logic [63:0] S64;  // 64'd9         -> 64  (no bail)
    int unsigned B;    // unsigned'(64) -> 32
    logic [64:0] S65;  // 65'd11        -> 65  (stamped, THEN the bail)
    int unsigned C;    // unsigned'(64) -> 64  (after the bail)
  } u_t;
  typedef struct packed { int unsigned X; logic G; } r_t;
  function automatic r_t build(u_t c);
    r_t r;
    r.X = c.A;
    r.G = (c.B > 0);
    return r;
  endfunction
  localparam u_t BASE = '{ A: 64, S64: 64'd9, B: unsigned'(64), S65: 65'd11,
                           C: unsigned'(64) };
endpackage
module dut #(parameter pk::r_t R = pk::build(pk::BASE)) (output logic [31:0] o);
  assign o = R.X;
endmodule
