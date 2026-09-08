// r10uvm217 grid arm C — WHAT RIDES THE DEEP HOP, BY KIND.
// Every declaration kind the package listing models — int, string, a typedef'd
// packed vector, a class handle, the three DYNAMIC containers — plus the
// unpacked aggregate both producers decline, plus the HOISTED body locals of
// an out-of-body constructor, reached through ONE extra package hop.
package pc0;
  int c0_int;
  string c0_str;
  typedef logic [3:0] c0_t;
  c0_t c0_vec;
  class Cc0;
    extern function new();
    int c0_prop;
  endclass
  function Cc0::new();
    int c0_loc_a;
    string c0_loc_b;
    c0_prop = c0_loc_a;
  endfunction
  Cc0 c0_h;
  int c0_assoc[string];
  int c0_q[$];
  int c0_dyn[];
  int c0_fixed[4];
endpackage

package pc1;
  import pc0::*;
endpackage

module gc_deep;
  import pc1::*;
  logic gc_deep_clk;
endmodule

module gc_near;
  import pc0::*;
  logic gc_near_clk;
endmodule
