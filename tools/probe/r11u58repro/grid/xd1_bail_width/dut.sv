// r11u58 xd1 — THE WIDTH BAIL.  Same reader as wd3/xd3, but member 2 is 128
// bits wide.  CompileHelper::expandPatternAssignment's per-operand loop does
// `int shift = (csize - 1 - i); if (shift < 0 || shift >= 64) return result;`
// AFTER adjustOpSize has already stamped that operand, so PREDICT: A stamped
// to 32, W stamped to 128, and B / D / F keep their COMPILED sizes (64 / 32 /
// 8) because the walk never reaches them.
package pk;
  typedef struct packed {
    int unsigned  A;   // 64            -> 32   (stamped)
    logic [127:0] W;   // 128'({..})    -> 128  (stamped, then the walk returns)
    int unsigned  B;   // unsigned'(64) -> 64   (UNSTAMPED: after the bail)
    logic [7:0]   D;   // 32'(5)        -> 32   (UNSTAMPED)
    logic [15:0]  F;   // 8'(3)         -> 8    (UNSTAMPED)
  } u_t;
  typedef struct packed { int unsigned X; logic G; } r_t;
  function automatic r_t build(u_t c);
    r_t r;
    r.X = c.A;
    r.G = (c.B > 0);
    return r;
  endfunction
  localparam u_t BASE = '{ A: 64, W: 128'({64'b0, 64'b0}), B: unsigned'(64),
                           D: 32'(5), F: 8'(3) };
endpackage
module dut #(parameter pk::r_t R = pk::build(pk::BASE)) (output logic [31:0] o);
  assign o = R.X;
endmodule
