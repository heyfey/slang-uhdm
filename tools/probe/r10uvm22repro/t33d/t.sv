// t33d — does a foreach over `this.<prop>` resolve through a SUBROUTINE FORMAL
// that SHADOWS the property name?  (uvm_reg_block::get_registers writes
// `foreach (this.regs[rg])` inside `get_registers(ref uvm_reg regs[$])`, and
// golden resolves it in Scoreboard / SimpleUVM where § classPropUnitImport21
// says a class property must NOT resolve.)
//
// The arm is built so the two candidate routes give DIFFERENT answers:
//   property route : `int p_a[string]`  -> string_var  (assoc INDEX rule)
//                    ...and, gated off by the $unit import below, int_var
//   formal   route : `ref Cel p_a[$]`   -> class_var 'Cel'  (an io_decl carries
//                    the ELEMENT typespec, § foreachAssocIdxLocalOnly20)
// `p_b` is the control: same shape, NO shadowing formal.
package pk;
  class Cel;
    int v;
  endclass
  class C;
    int p_a[string];
    int p_b[string];
    string p_s;
    extern function void run(ref Cel p_a[$]);
  endclass
  function void C::run(ref Cel p_a[$]);
    foreach (this.p_a[i]) $display("a %0d", i);
    foreach (this.p_b[j]) $display("b %0d", j);
    foreach (this.p_s[k]) $display("s %0d", k);
  endfunction
endpackage

import pk::*;

module top;
  pk::C c;
  initial c = new();
endmodule
