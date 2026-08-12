// r10earl29 VERIFIER arm v10 — the STRING-LITERAL abstention, measured instead of
// read.  Eight lines of the surelog corpus carry exactly this shape
//   cov.sticky_intr_cov[{"gpio_sticky_intr_pin", $sformatf("%0d", each_bit)}]
//   scoreboard.item_fifos[{"a_chan_", xbar_hosts[i].host_name}]
// (Opentitan, SLANG_REJECT today), and the shipped law claims a string element
// falls through `default: return false` so the whole index keeps its raw text.
// This arm builds a measurable stand-in: an associative array member indexed by a
// concatenation of a string literal and a string variable.
module v10_str (
    output logic [7:0] o1
);
  typedef struct {logic [7:0] m[string];} sq_t;
  sq_t   q;
  string s;
  // A dynamic-type member may only be read in a PROCEDURAL context (slang
  // -Wdynamic-non-procedural rejects the continuous assign).
  always_comb o1 = q.m[{"a_chan_", s}];
endmodule
