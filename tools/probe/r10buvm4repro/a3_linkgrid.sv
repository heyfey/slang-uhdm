// r10buvm4 arm a3 — THE REFUTATION ARM.  a1/a2 said a `func_call` written with
// NAMED association carries ONE argument PER FORMAL with a `0` placeholder in
// every unwritten slot.  BuildUVMPkg said otherwise at `uvm_pkg.sv:12476`.
// The difference between those cells is NOT the receiver and NOT the UHDM
// object kind: it is whether Surelog had RESOLVED the callee when it compiled
// the call — every slot-filled golden call carries `vpiFunction`, and 12476's
// does not, because `uvm_default_factory::m_matches_type_override` is
// prototyped inside the class and DEFINED OUT-OF-BODY 1000 lines later.
//
// This arm reproduces both sides of that in one file.
package p3;

  class oob;
    int acc;
    // L1 — prototyped here, DEFINED OUT-OF-BODY BELOW: the corpus shape.
    extern function int later(int a = 0, int b = 0, int c = 0, int d = 0);
    // L2 — defined IN PLACE, above its callers: the a2 shape.
    function int sooner(int a = 0, int b = 0, int c = 0, int d = 0);
      return a + b + c + d;
    endfunction
    function void go;
      // M1 — call of the OUT-OF-BODY callee, named, formals skipped.
      acc = later(.b(1), .c(2));
      // M2 — call of the IN-PLACE callee, named, formals skipped.
      acc = sooner(.b(1), .c(2));
      // M3 — the out-of-body callee, named, EVERY formal written, reordered.
      acc = later(.d(4), .b(1), .a(0), .c(2));
      // M4 — the out-of-body callee, POSITIONAL control.
      acc = later(0, 1);
    endfunction
  endclass

  function int oob::later(int a = 0, int b = 0, int c = 0, int d = 0);
    return a + b + c + d;
  endfunction

endpackage

module a3_linkgrid;
  p3::oob h;
  initial begin
    h = new();
    h.go();
  end
endmodule
