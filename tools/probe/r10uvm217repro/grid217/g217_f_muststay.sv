// r10uvm217 grid arm F — THE MUST-STAY CONTROL.
// § oobCtorLocalsRideTheImport203's own shape with NO transitive import
// anywhere: a package with its own data declarations and an out-of-body
// constructor whose body locals Surelog hoists, materialised at multiplicity
// 2 (file scope) and 3 (file + module scope).  Not one cell of this arm may
// move between the two binaries.
package pf0;
  int f0_own0;
  class Cf0;
    extern function new();
    int f0_prop;
  endclass
  function Cf0::new();
    int f0_loc_a;
    string f0_loc_b;
    begin
      int f0_loc_c;
      f0_prop = f0_loc_c;
    end
    f0_prop = f0_loc_a;
  endfunction
  string f0_own1;
endpackage

import pf0::*;

module gf_file;
  logic gf_file_clk;
endmodule

module gf_both;
  import pf0::*;
  logic gf_both_clk;
endmodule
