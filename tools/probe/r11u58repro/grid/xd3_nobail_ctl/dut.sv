// r11u58 xd3 — NO-BAIL CONTROL.  wd3 with every element constant-reducible and
// every member width <= 64, so the producer's per-operand walk never returns
// early.  PREDICT: all five elements carry their member's width.
package pk;
  parameter int unsigned NR = 2;
  typedef struct packed {
    int unsigned A;   // bare literal 64        -> 32
    int unsigned B;   // unsigned'(64)          -> 32
    logic [7:0]  D;   // 32'(5)                 -> 8
    int unsigned E;   // NR + 1 (an operation)  -> 32
    logic [15:0] F;   // 8'(3)                  -> 16 (WIDENS)
  } u_t;
  typedef struct packed { int unsigned X; logic G; } r_t;
  function automatic r_t build(u_t c);
    r_t r;
    r.X = c.A;
    r.G = (c.B > 0);
    return r;
  endfunction
  localparam u_t BASE = '{ A: 64, B: unsigned'(64), D: 32'(5), E: NR + 1, F: 8'(3) };
endpackage
module dut #(parameter pk::r_t R = pk::build(pk::BASE)) (output logic [31:0] o);
  assign o = R.X;
endmodule
