// v11u58 va10 — A PATTERN THAT DOES NOT NAME EVERY MEMBER.  `default:` makes
// the producer's flatten fill the rest; the patch refuses to stamp (its member
// presence check fails outright).  Measure what golden does.
package pk;
  typedef struct packed {
    int unsigned A;   // 64
    int unsigned B;   // 64
    logic [7:0]  D;   // 32'(5)
  } u_t;
  typedef struct packed { int unsigned X; logic G; } r_t;
  function automatic r_t build(u_t c);
    r_t r;
    r.X = c.A;
    r.G = (c.B > 0);
    return r;
  endfunction
  localparam u_t P = '{ A: 64, default: 32'(5) };
endpackage
module dut #(parameter pk::r_t R = pk::build(pk::P)) (output logic [31:0] o);
  assign o = R.X;
endmodule
