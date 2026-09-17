// v11u59 xv2 — THE GATE'S WIDTH BOUNDARY.  § patElabUintResize skips a member
// whose width is 0 or >= 64.  Cut 63 / 64 / 65 with over-wide values, so the
// arm proves the removal changes nothing on the skipped side and the right
// thing on the kept side.  A 63-bit member fed 2**63+5 is the widest cell the
// arm can reach; a 64-bit member fed the same value is the first it cannot.
package pk;
  localparam longint unsigned V63 = 64'd9223372036854775813; // 2**63 + 5
  localparam longint unsigned V64 = 64'd18446744073709551615;
  localparam int unsigned      SM = 300;
  typedef struct packed {
    logic [62:0]  A63;  // V63 -> reachable, over-wide by one bit
    logic [63:0]  A64;  // V64 -> gate skips (width >= 64)
    logic [64:0]  A65;  // V63 -> gate skips
    logic [0:0]   A1;   // SM  -> reachable, maximally over-wide
    logic [127:0] W;    // 128'(0) -> the walk returns here
    int unsigned  Z;
  } u_t;
  typedef struct packed { int unsigned X; logic G; } r_t;
  function automatic r_t build(u_t c);
    r_t r;
    r.X = c.A63[31:0];
    r.G = c.A1;
    return r;
  endfunction
  localparam u_t BASE = '{ A63: V63, A64: V64, A65: V63, A1: SM,
                           W: 128'(0), Z: unsigned'(64) };
endpackage
module dut #(parameter pk::r_t R = pk::build(pk::BASE)) (output logic [31:0] o);
  assign o = R.X;
endmodule
