// v11u82 v4 -- LAW A BREAK: the SAME definition instantiated TWICE, each
// elaborated copy carrying the written-path cell.  Withholding the push must
// not leave one copy sharing the other's slot.
package p;
  typedef struct packed { int unsigned n; logic [7:0] t; } cfg_t;
  function automatic cfg_t build(int unsigned x);
    cfg_t c; c.n = x; c.t = 8'h5A; return c;
  endfunction
endpackage

module kid #(parameter int unsigned S = 600) (output logic [31:0] q);
  localparam p::cfg_t K_LOC = p::build(S);
  logic [31:0] k_own;  assign k_own  = K_LOC.n;       // simple (control)
  logic [31:0] k_path; assign k_path = kid.K_LOC.n;   // written path, own module
  assign q = k_own ^ k_path;
endmodule

module dut (output logic [31:0] o);
  logic [31:0] a, b;
  kid #(.S(600)) u1 (.q(a));
  kid #(.S(700)) u2 (.q(b));
  assign o = a ^ b;
endmodule
