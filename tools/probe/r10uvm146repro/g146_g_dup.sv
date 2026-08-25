// r10uvm146 arm G — the same wildcard import written THREE times at $unit
// scope.  slang collapses the three into one WildcardImportSymbol; Surelog
// lists the package's parameters once per import ITEM.  The listing must be
// three deep on both sides.
package pp_dup;
  parameter DA = 1;
endpackage
import pp_dup::*;
import pp_dup::*;
import pp_dup::*;
module m_dup(output int o);
  assign o = DA;
endmodule
