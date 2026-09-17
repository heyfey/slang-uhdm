// v11u58 va22 — TWO LEVELS OF DEADNESS: the gated read is in `deep`, which is
// instantiated only by `mid`, which is instantiated only inside `if (0)`.
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
  localparam u_t N1 = '{ A: 64, B: unsigned'(64), D: 32'(5) };  // DEAD, 2 levels
endpackage
module deep #(parameter pk::r_t R = pk::build(pk::N1)) (output logic [31:0] q);
  assign q = R.X;
endmodule
module mid (output logic [31:0] q);
  deep d0 (.q(q));
endmodule
module dut (output logic [31:0] o);
  logic [31:0] w;
  if (0) begin : dead
    mid m0 (.q(w));
  end
  assign o = 32'd1;
endmodule
