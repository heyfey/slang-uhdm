// v11u58 va13 — A VALUE THAT DOES NOT FIT ITS MEMBER.  `adjustUnsized` writes
// only an UNSIZED '1, so the producer should re-size WITHOUT masking; the
// landed § patElabUintResize arm masks a REFERENCE element's value.  Measure
// both: a literal 300 into an 8-bit member and a reference 300 into another.
package pk;
  localparam int unsigned BIG = 300;
  typedef struct packed {
    int unsigned A;   // 64            -> 32
    logic [7:0]  L;   // 300 literal   -> 8 ?   value masked?
    logic [7:0]  M;   // BIG reference -> 8 ?   value masked?
  } u_t;
  typedef struct packed { int unsigned X; logic G; } r_t;
  function automatic r_t build(u_t c);
    r_t r;
    r.X = c.A;
    r.G = (c.L > 0);
    return r;
  endfunction
  localparam u_t BASE = '{ A: 64, L: 300, M: BIG };
endpackage
module dut #(parameter pk::r_t R = pk::build(pk::BASE)) (output logic [31:0] o);
  assign o = R.X;
endmodule
