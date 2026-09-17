// v11u59 xv5 — DEAD HIERARCHY AND MULTIPLE INSTANCES.  Pass 57's re-stamp
// carries a LIVENESS filter so a dead generate branch cannot arm it; the same
// package pattern is read from a live instance, a dead generate branch and a
// second instance with a different override.  If the removal makes the element
// depend on WHICH read stamped it last, the two instances diverge here.
package pk;
  localparam int unsigned BIG = 300;
  localparam int unsigned SML = 7;
  typedef struct packed {
    logic [7:0]   M;   // BIG -> over-wide
    logic [3:0]   N;   // SML -> fits
    logic [127:0] W;
    int unsigned  Z;
  } u_t;
  typedef struct packed { int unsigned X; logic G; } r_t;
  function automatic r_t build(u_t c);
    r_t r;
    r.X = c.Z;
    r.G = (c.M > 0);
    return r;
  endfunction
  localparam u_t BASE = '{ M: BIG, N: SML, W: 128'(0), Z: unsigned'(64) };
endpackage
module leaf #(parameter pk::r_t R = pk::build(pk::BASE)) (output logic [31:0] o);
  assign o = R.X;
endmodule
module dut (output logic [31:0] o);
  logic [31:0] a, b;
  leaf u_live (.o(a));
  if (0) begin : dead
    leaf u_dead (.o());
  end
  leaf #(.R(pk::build(pk::BASE))) u_second (.o(b));
  assign o = a ^ b;
endmodule
