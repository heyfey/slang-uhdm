// r10uvm217 grid arm D — THE IMPORTER KIND.
// The same two-package chain reached from a MODULE, an INTERFACE, a PROGRAM
// and a PACKAGE.  The interface cell is § oobCtorLocalsRideTheImport203's R2
// (our hoist is called from the module emitters only) and is RECORDED as a
// pre-existing residue, not claimed.
package pd0;
  int d0_v;
  string d0_s;
endpackage

package pd1;
  import pd0::*;
  int d1_v;
endpackage

package pd2;
  import pd1::*;
  int d2_v;
endpackage

interface gd_if;
  import pd1::*;
  logic gd_if_clk;
endinterface

program gd_pg;
  import pd1::*;
  initial begin
  end
endprogram

module gd_mod;
  import pd1::*;
  gd_if u_if();
  logic gd_mod_clk;
endmodule
