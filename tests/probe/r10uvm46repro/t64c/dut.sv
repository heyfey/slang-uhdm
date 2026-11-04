// r10uvm46 arm t64c — THE PREDICATE CELL.  Source-read of Surelog says the
// distinguisher is NOT `local` and NOT the two-token return type but the PAIR
// (any class-item qualifier) + (an explicitly written LIFETIME):
//
//   CompileClass::compile_class_method_ hands `compileFunction` the UNADVANCED
//   `fC->Child(id)` — the QUALIFIER node.  `setFuncTaskQualifiers` unwraps a
//   `Function_declaration` into its child ONLY when the node handed in IS the
//   Function_declaration (its first `if`, CompileStmt.cpp:1844); reached through
//   the qualifier loop instead, it consumes the qualifier and RETURNS the
//   Function_declaration unwrapped, so `compileFunction`'s own `Child()` lands
//   on the `Lifetime_Automatic` node rather than the Function_body_declaration.
//   Name, Tf_port_list and body all derive from there and all come out invalid;
//   vpiVisibility survives (its `if` did fire) and vpiAutomatic does NOT (its
//   `if` never saw the node).  That is exactly the six fields measured on t64a.
//
// If that reading is right, `virtual`/`static` must break it too, and a written
// `static` LIFETIME must break it as well as `automatic`.  Each class is
// separate so the collapse-onto-one-key artifact cannot confuse the reading.
package p66;

  class c66a;                       // virtual + automatic
    virtual function automatic int f_virt_auto(int a);
      return a;
    endfunction
  endclass

  class c66b;                       // static (class-item) + automatic
    static function automatic int f_stat_auto(int a);
      return a;
    endfunction
  endclass

  // c66c — local + a written STATIC lifetime — lives in c66c.sv, NOT here:
  // slang enforces the LRM ("class methods cannot have static lifetime") and
  // REJECTS it, so keeping it in this file would make the whole arm
  // SLANG_REJECT and unusable as an ours-side comparison.  Its golden IS
  // measured (c66c.sv, read with gold.sh): `function ''`, vis=3, nio=0,
  // stmt unset, autom=0 — i.e. the artifact fires on a written `static`
  // lifetime exactly as on `automatic`, which is what the source read predicts
  // and which our side can never reach.

  class c66d;                       // CONTROL: virtual alone
    virtual function int f_virt(int a);
      return a;
    endfunction
  endclass

  class c66e;                       // CONTROL: static (class-item) alone
    static function int f_stat(int a);
      return a;
    endfunction
  endclass

  class c66f;                       // CONTROL: a written lifetime alone
    function automatic int f_auto(int a);
      return a;
    endfunction
  endclass

endpackage

module t64c;
  initial begin
    p66::c66a h;
    h = new();
  end
endmodule
