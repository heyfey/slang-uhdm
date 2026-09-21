// r11u82 s1 -- LAW A at MODULE LEVEL: is the "written path does not fold" rule
// the gen scope's, or the reference form's everywhere?  Every row is the SAME
// member of the SAME module-level base; only the WRITTEN FORM varies.
package p;
  typedef struct packed { int unsigned n; logic [7:0] t; } cfg_t;
  function automatic cfg_t build(int unsigned x);
    cfg_t c; c.n = x; c.t = 8'h5A; return c;
  endfunction
endpackage

module dut (output logic [31:0] o);
  localparam p::cfg_t M_LOC = p::build(600);
  logic [31:0] m_simple; assign m_simple = M_LOC.n;       // simple name  (control)
  logic [31:0] m_path;   assign m_path   = dut.M_LOC.n;   // written path, own module
  logic [7:0]  m_simt;   assign m_simt   = M_LOC.t;       // the other member, simple
  logic [7:0]  m_patht;  assign m_patht  = dut.M_LOC.t;   // the other member, path
  assign o = m_simple ^ m_path ^ {24'd0, m_simt} ^ {24'd0, m_patht};
endmodule
