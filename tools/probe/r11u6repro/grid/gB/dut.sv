// gB — NEGATIVE CONTROL for § pkgParamDefTsQueryArgRef: the $clog2 argument
// names a parameter in ANOTHER package, which Surelog SUBSTITUTES even in the
// def listing.  The law must not spare this one.
package q;
  parameter int QW = 32;
endpackage
package p;
  import q::*;
  typedef logic [q::QW-1:0][$clog2(q::QW)-1:0] perm_t;
  parameter perm_t PermDflt = {160'h1e35ecba467fd1b12e958152c04fa43878a8daed};
endpackage
module top;
  import p::*;
  logic [31:0] x;
  assign x = PermDflt[0];
endmodule
