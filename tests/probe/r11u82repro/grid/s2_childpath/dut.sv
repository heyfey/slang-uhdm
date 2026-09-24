// r11u82 s2 -- the base lives in a CHILD INSTANCE and is reached by a written
// path from the parent's module level, and by a simple name inside the child.
package p;
  typedef struct packed { int unsigned n; logic [7:0] t; } cfg_t;
  function automatic cfg_t build(int unsigned x);
    cfg_t c; c.n = x; c.t = 8'h5A; return c;
  endfunction
endpackage

module kid (output logic [31:0] q);
  localparam p::cfg_t K_LOC = p::build(700);
  logic [31:0] k_simple; assign k_simple = K_LOC.n;       // simple, in the child
  assign q = k_simple;
endmodule

module dut (output logic [31:0] o);
  logic [31:0] w;
  kid u1 (.q(w));
  logic [31:0] c_path; assign c_path = u1.K_LOC.n;        // written path, into a child
  assign o = w ^ c_path;
endmodule
