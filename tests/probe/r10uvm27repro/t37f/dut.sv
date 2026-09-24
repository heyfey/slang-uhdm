// r10uvm27 t37f — the CLASS-ITEM QUALIFIER arm of the constructor laws.
// CompileClass.cpp advances `func_decl` past the qualifiers to classify the
// method, but then hands compileClassConstructorDeclaration the UNADVANCED
// `fC->Child(id)` — the qualifier node itself — while compileFunction re-runs
// setFuncTaskQualifiers internally.  Prediction: a qualified constructor loses
// BOTH its io_decls and its whole body, whatever the body holds.  This is the
// shape of all 21 `uvm_*_phase::new` (`protected function new(string
// name="build"); super.new(name); endfunction`).
package pk;

  class base;
    int b;
    function new(int x = 1);
      b = x;
    endfunction
    function void mark();
      b = 9;
    endfunction
  endclass

  // qualified, WITH a port list, super.new + 1 statement
  class g_prot_pl extends base;
    int a;
    protected function new(int k = 3);
      super.new(k);
      a = 1;
    endfunction
  endclass

  // qualified `local`, WITH a port list, 2 statements
  class g_local_pl extends base;
    int a, c;
    local function new(int k = 3);
      a = 1;
      c = 2;
    endfunction
  endclass

  // qualified, NO port list, 3 statements
  class g_prot_np extends base;
    int a, c, d;
    protected function new();
      a = 1;
      c = 2;
      d = 3;
    endfunction
  endclass

  // UNqualified control with the same body as g_prot_pl
  class g_plain_pl extends base;
    int a;
    function new(int k = 3);
      super.new(k);
      a = 1;
    endfunction
  endclass

  // a qualified ordinary METHOD control: compileFunction re-runs the
  // qualifier skip, so this one must keep io_decls and body
  class g_prot_method extends base;
    int a, c;
    protected function void go(int k);
      a = k;
      c = 2;
    endfunction
  endclass

endpackage

module top;
  pk::g_plain_pl h;
  initial h = new(1);
endmodule
