// r11u58 xd2b — THE NON-CONSTANT BAIL, FuncStructVal's own face.  `pq` is
// declared AFTER `pk`, so `pq::EA` is still an unresolved ref_obj when pk's
// pattern is walked (exactly `config_pkg::NOC_TYPE_AXI4_ATOP` in FuncStructVal,
// whose package is declared after cva6_config_pkg in the same file).
// PREDICT: A stamped to 32; N stays a ref_obj; B / D / F keep their COMPILED
// sizes 64 / 32 / 8 because the producer's per-operand walk returns at N.
package pk;
  typedef struct packed {
    int unsigned A;
    pq::e_t      N;
    int unsigned B;
    logic [7:0]  D;
    logic [15:0] F;
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
package pq;
  typedef enum logic [1:0] { EA = 0, EB = 1 } e_t;
endpackage
module dut #(parameter pk::r_t R = pk::build(pk::BASE)) (output logic [31:0] o);
  assign o = R.X;
endmodule
