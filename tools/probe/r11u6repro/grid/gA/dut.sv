// gA — THE HEAD.  A package vector typedef whose second dim bound is
// $clog2(<same-package parameter>), and a package parameter typed by it.
package p;
  parameter int LfsrWidth = 32;
  typedef logic [LfsrWidth-1:0][$clog2(LfsrWidth)-1:0] perm_t;
  parameter perm_t PermDflt = {160'h1e35ecba467fd1b12e958152c04fa43878a8daed};
endpackage
module top;
  import p::*;
  logic [LfsrWidth-1:0] x;
  assign x = PermDflt[0];
endmodule
