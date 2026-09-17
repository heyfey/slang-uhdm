// v11u58 va15 — THE LANDED § patElabUintResize MASKING ARM, re-cut inside the
// BAILED (tagged) state, where golden's own cells are readable.  `M`'s written
// value is a REFERENCE whose value (300) does not fit its 8-bit member; the
// landed arm masks such an element's VALUE as well as its size.  Does golden?
package pk;
  localparam int unsigned BIG = 300;
  typedef struct packed {
    logic [7:0]   M;   // BIG           -> 8, value 300 or masked 44?
    logic [127:0] W;   // 128'(0)       -> 128, then the walk returns
    int unsigned  Z;   // unsigned'(64) -> stays 64
  } u_t;
  typedef struct packed { int unsigned X; logic G; } r_t;
  function automatic r_t build(u_t c);
    r_t r;
    r.X = c.Z;
    r.G = (c.M > 0);
    return r;
  endfunction
  localparam u_t BASE = '{ M: BIG, W: 128'(0), Z: unsigned'(64) };
endpackage
module dut #(parameter pk::r_t R = pk::build(pk::BASE)) (output logic [31:0] o);
  assign o = R.X;
endmodule
