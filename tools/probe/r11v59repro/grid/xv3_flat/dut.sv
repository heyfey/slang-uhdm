// v11u59 xv3 — THE COMPLETED WALK (the FLAT state).  No member is 128 bits, so
// the producer's positional walk COMPLETES and golden's elaborated listing is
// FLAT (untagged, positional) while ours stays TAGGED.  The mask removal
// changes the values inside our tagged elements on a row where golden has no
// tagged elements at all: the question is whether a NEW cmp head arrives
// EARLIER in the walk (the falling-count trap) once the values change.
package pk;
  localparam int unsigned BIG = 300;
  typedef struct packed {
    logic [7:0]  M8;   // BIG -> over-wide
    logic [3:0]  M4;   // BIG -> over-wide
    int unsigned Z;    // unsigned'(64)
  } u_t;
  typedef struct packed { int unsigned X; logic G; } r_t;
  function automatic r_t build(u_t c);
    r_t r;
    r.X = c.Z;
    r.G = (c.M8 > 0);
    return r;
  endfunction
  localparam u_t BASE = '{ M8: BIG, M4: BIG, Z: unsigned'(64) };
endpackage
module dut #(parameter pk::r_t R = pk::build(pk::BASE)) (output logic [31:0] o);
  assign o = R.X;
endmodule
