// v11u58 va3 — A GATED READ THAT IS NEVER ELABORATED.  `inner`'s parameter
// default carries the call-argument read, so the SYNTAX gate fires, but
// `inner` is instantiated only inside `generate if (0)`.  If Surelog never
// elaborates it, `getValue("pk::G1")` never runs and golden NEVER stamps,
// while the patched exporter stamps from the syntax alone: pristine-right ->
// patched-wrong.  G2 is the same parameter read by a LIVE instance (the
// positive control inside the same arm).
package pk;
  typedef struct packed {
    int unsigned A;   // 64
    int unsigned B;   // unsigned'(64)
    logic [7:0]  D;   // 32'(5)
  } u_t;
  typedef struct packed { int unsigned X; logic G; } r_t;
  function automatic r_t build(u_t c);
    r_t r;
    r.X = c.A;
    r.G = (c.B > 0);
    return r;
  endfunction
  localparam u_t G1 = '{ A: 64, B: unsigned'(64), D: 32'(5) };  // DEAD reader
  localparam u_t G2 = '{ A: 64, B: unsigned'(64), D: 32'(5) };  // LIVE reader
endpackage
module inner #(parameter pk::r_t R = pk::build(pk::G1)) (output logic [31:0] q);
  assign q = R.X;
endmodule
module live #(parameter pk::r_t R = pk::build(pk::G2)) (output logic [31:0] q);
  assign q = R.X;
endmodule
module dut (output logic [31:0] o);
  logic [31:0] w;
  if (0) begin : dead
    inner i0 (.q(w));
  end
  live l0 (.q(o));
endmodule
