// t40d — the PACKAGE-scope variable initializer.  Once § noDirNamedType
// DefaultDropped30 and § pureVirtIoDecls30 cleared the io_decl census, the
// uhdm-cmp DESIGN head on Scoreboard and SimpleUVM is a package variable:
//   uvm_table_printer uvm_default_table_printer = new();
// golden gives it a `method_func_call 'new'` vpiExpr and we give it none.
// Pass 29 fixed exactly this shape for a CLASS PROPERTY
// (§ classPropNewInit29); this arm asks the package-scope half, at the same
// spellings, plus the two neighbours (a module-scope variable and a
// $unit-scope one) so the rule's scope is read, not assumed.
package p40d;
  class k40; int z; endclass
  class k40a; function new(int a = 1); endfunction endclass

  // the UVM shape
  k40  g_new       = new();
  k40  g_new_bare  = new;
  k40a g_new_args  = new(3);
  // controls: a non-class initializer at the same scope
  int  g_int       = 7;
  string g_str     = "s";
  // a class handle with NO initializer, and one initialised to null
  k40  g_none;
  k40  g_null      = null;
endpackage

module top40d;
  import p40d::*;
  // module-scope
  k40 m_new = new();
  int m_int = 7;
  initial begin
    if (g_new == null || m_new == null) $display("x");
  end
endmodule
