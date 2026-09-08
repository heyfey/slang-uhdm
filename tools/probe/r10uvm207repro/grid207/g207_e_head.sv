// r10uvm207 arm E — THE MINIMISED CORPUS HEAD.  uvm-1.2's
// `uvm_reg_map.svh:408-412` struct `uvm_reg_map_addr_range { uvm_reg_addr_t
// min; uvm_reg_addr_t max; int unsigned stride; }` and `uvm_reg_map.svh:963`
// `uvm_reg_map_addr_range range;` inside the OUT-OF-BODY class method
// `uvm_reg_map::m_set_mem_offset`, wildcard-imported.  This arm's pristine head
// must be the corpus head's exact shape.
package p207a_e;
  typedef bit [63:0] bt207e;
  typedef struct { bt207e e_min207; bt207e e_max207; int e_stride207; } se207;

  class C207e;
    extern function int m_set207();
  endclass

  function int C207e::m_set207();
    se207 range207;                       // the corpus's `range`
    return int'(range207.e_min207) + int'(range207.e_max207);
  endfunction
endpackage

package p207b_e;
  import p207a_e::*;
  function automatic int gb207e();
    C207e c207e;
    c207e = new();
    return c207e.m_set207();
  endfunction
endpackage

module g207_e_head;
  import p207b_e::*;
  int r207e;
  initial r207e = gb207e();
endmodule
