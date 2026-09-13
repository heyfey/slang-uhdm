// d14 — TOP vs CHILD, DEFAULT vs OVERRIDE: which of the two is the
// distinguisher for the elaborated fold.
package p;
  typedef struct packed { int unsigned n; logic [63:0] base; } cfg_t;
  function automatic cfg_t build(int unsigned k);
    cfg_t r;  r.n = k;  r.base = 64'h1000;  return r;
  endfunction
endpackage

module kid_def #(parameter p::cfg_t C = p::build(1)) (output logic [31:0] o);
  assign o = C.n;
endmodule
module kid_ovr #(parameter p::cfg_t C = p::build(1)) (output logic [31:0] o);
  assign o = C.n;
endmodule
module kid_loc (output logic [31:0] o);
  localparam p::cfg_t L = p::build(6);
  assign o = L.n;
endmodule

module dut (output logic [31:0] a, b, c, t);
  parameter p::cfg_t T = p::build(8);
  assign t = T.n;                       // TOP, default
  kid_def u0 (.o(a));                   // CHILD, default
  kid_ovr #(.C(p::build(9))) u1 (.o(b));// CHILD, override
  kid_loc u2 (.o(c));                   // CHILD, own localparam
endmodule
