// v11u84 v1 — LAW C vs THE HOISTED OUT-OF-BODY CONSTRUCTOR LOCAL.
// r11u84's census counts only pkg.members() Variable/Net as "decls", so a
// package whose only pre-import entries are HOISTED ctor locals reads
// decls=0 / SAME.  But the pre-84 walk flushed the hoist queue at the IMPORT
// SLOT (flushHoist9(impAt8)) and the patched walk does not, so the hoisted
// entries move ACROSS the clone batch.  Golden decides which side is right.
package hm1;
  wire  [7:0] h_net;
  logic [7:0] h_var = 8'd3;
  typedef logic [7:0] hw_t;
  wire  hw_t  h_wtd;
endpackage

package hp1;                    // class + out-of-body new BEFORE the import
  class c1;
    int cx;
    extern function new();
  endclass
  function c1::new();
    int hl_a = 1;
    logic [3:0] hl_b;
    cx = hl_a + 32'(hl_b);
  endfunction
  import hm1::*;
  logic [7:0] own_var_z;
  wire  [7:0] own_net_z;
endpackage

package hp2;                    // the control: the import comes FIRST
  import hm1::*;
  class c2;
    int cy;
    extern function new();
  endclass
  function c2::new();
    int hl_c = 2;
    cy = hl_c;
  endfunction
  logic [7:0] own_var_y;
endpackage

module dut (output logic [31:0] o);
  import hp1::*;
  import hp2::*;
  assign o = {24'd0, own_net_z ^ own_var_z};
endmodule
