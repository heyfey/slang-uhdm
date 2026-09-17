// v11u58 va16 — THE SAME GATED READ IN A MODULE INSTANTIATED TWICE, with
// different overrides.  The elaborated PACKAGE listing is ONE object; does it
// take the stamp once and consistently?
package pk;
  typedef struct packed {
    int unsigned A;   // 64
    int unsigned B;   // unsigned'(64)
    logic [7:0]  D;   // 32'(5)
  } u_t;
  typedef struct packed { int unsigned X; logic G; } r_t;
  function automatic r_t build(u_t c, int unsigned k);
    r_t r;
    r.X = c.A + k;
    r.G = (c.B > 0);
    return r;
  endfunction
  localparam u_t M = '{ A: 64, B: unsigned'(64), D: 32'(5) };
endpackage
module leaf #(parameter int unsigned K = 1,
              parameter pk::r_t R = pk::build(pk::M, K)) (output logic [31:0] q);
  assign q = R.X;
endmodule
module dut (output logic [31:0] o);
  logic [31:0] a, b;
  leaf #(.K(1)) l1 (.q(a));
  leaf #(.K(7)) l2 (.q(b));
  assign o = a + b;
endmodule
