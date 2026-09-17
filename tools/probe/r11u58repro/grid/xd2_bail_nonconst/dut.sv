// r11u58 xd2 — THE NON-CONSTANT BAIL, the shape FuncStructVal carries.  An
// element that reduceExpr cannot fold to a value (a CROSS-PACKAGE enum
// reference, exactly `config_pkg::NOC_TYPE_AXI4_ATOP` in FuncStructVal) sets
// invalidValue in the producer's per-operand walk, and the loop returns.
// PREDICT: A stamped to 32, N left a ref_obj, and B / D / F keep their
// COMPILED sizes (64 / 32 / 8).
package pq;
  typedef enum logic [1:0] { EA = 0, EB = 1 } e_t;
endpackage
package pk;
  typedef struct packed {
    int unsigned A;   // 64            -> 32   (stamped)
    pq::e_t      N;   // pq::EA        -> a ref_obj; the walk returns here
    int unsigned B;   // unsigned'(64) -> 64   (UNSTAMPED)
    logic [7:0]  D;   // 32'(5)        -> 32   (UNSTAMPED)
    logic [15:0] F;   // 8'(3)         -> 8    (UNSTAMPED)
  } u_t;
  typedef struct packed { int unsigned X; logic G; } r_t;
  function automatic r_t build(u_t c);
    r_t r;
    r.X = c.A;
    r.G = (c.B > 0);
    return r;
  endfunction
  localparam u_t BASE = '{ A: 64, N: pq::EA, B: unsigned'(64), D: 32'(5), F: 8'(3) };
endpackage
module dut #(parameter pk::r_t R = pk::build(pk::BASE)) (output logic [31:0] o);
  assign o = R.X;
endmodule
