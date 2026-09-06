// r10v179 ADVERSARIAL ARM E — the axis r10uvm179's arm D left untested: a
// PACKAGE FREE FUNCTION / TASK whose local is a PARAMETERIZED-CLASS
// SPECIALIZATION (the one shape whose type the package's UN-ELABORATED listing
// cannot resolve), standing in the FACE position.  `pkgDefViewBody9` is TRUE
// for a package free body, so the patched predicate reaches it; golden's
// `UhdmWriter::lateBinding` mints nothing for a PACKAGE scope, so the law
// predicts BARE there and BOUND in the class-body/module listing.
// MEASUREMENT ONLY.
package pkg_victor;

  parameter int WID = 5;

  class Nub;
    int knob;
  endclass

  class Box #(int W = 1);
    int cargo;
  endclass

  class Dock;
    function int  poke(Nub n); return 0; endfunction
    function int  pokeb(Box #(WID) b); return 0; endfunction
    function void jabb(Box #(WID) b); endfunction
  endclass

  Dock pkg_dock;
  int  pkg_score;

  function void free_spec();
    Box #(WID) held;
    if (pkg_dock.pokeb(held) == 0) pkg_score = 1;      // e01 pkg free FUNCTION
  endfunction

  task free_spec_task();
    Box #(WID) held;
    if (pkg_dock.pokeb(held) == 0) pkg_score = 2;      // e02 pkg free TASK
  endtask

  function void free_spec_stmt();
    Box #(WID) held;
    pkg_dock.jabb(held);                               // e03 STATEMENT twin
  endfunction

  function void free_spec_d1();
    Box #(WID) held;
    if (pkg_score == 0) begin
      if (pkg_dock.pokeb(held) == 0) pkg_score = 3;    // e04 depth 1
    end
  endfunction

  function void free_res();
    Nub solid;
    if (pkg_dock.poke(solid) == 0) pkg_score = 4;      // e05 RESOLVED control
  endfunction

endpackage

module tb_victor;
  import pkg_victor::*;
  initial begin
    pkg_score = 0;
    free_spec();
  end
endmodule
