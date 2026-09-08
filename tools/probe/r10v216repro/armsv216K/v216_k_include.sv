// K — the export item and its definition live in DIFFERENT include buffers.
// `pkgTfOrder9` keys the package listing on a raw SourceLocation, so this is
// the cross-buffer comparison RESUME.md §9 warns about.
package v216_pkg_k;
  `include "k_exp.svh"
  function automatic int plain_k(int x);
    return x + 1;
  endfunction
  `include "k_def.svh"
endpackage
module v216_top_k;
  import v216_pkg_k::*;
  initial begin
    if (plain_k(1) == 0) $display("x");
  end
endmodule
