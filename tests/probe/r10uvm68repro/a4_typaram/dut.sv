// r10uvm68 arm a4 — a CLASS TYPE PARAMETER bound to `int`, at subroutine scope.
// § typeParamVarIsRefVar58 already makes these `ref_var`, and a ref_var carries
// no vpiSigned on either side, so this arm exists to prove this pass's law
// CANNOT reach them (a regression here would mean the gate was put above the
// ref_var gate instead of below it).
class C4 #(type TP = int);
  function void f();
    TP  z_typaram;
    int z_written;
    z_written = z_typaram;
  endfunction
  function TP r_tp(); r_tp = 0; endfunction
endclass
module m4_mod;
  C4 #(int) c4;
  initial c4 = new();
endmodule
