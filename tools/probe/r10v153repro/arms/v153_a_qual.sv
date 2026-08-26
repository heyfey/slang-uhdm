// r10v153 arm A — QUALIFIED READS of a colliding class property from an
// out-of-body package-scope method: `this.`, `super.`, `Class::` and
// `pkg::`, plus a dynamic-array `= new[]` lvalue.  LHS is always golden.
package pva153;

  int    v_int;
  int    v_this;
  int    v_sup;
  int    v_stat;
  int    v_dyn[];
  string v_str;

  class Bva153;
    int v_sup;
    function void bm153(); endfunction
  endclass

  class Dva153 extends Bva153;
    int        v_int;
    int        v_this;
    static int v_stat;
    int        v_dyn[];
    string     v_str;
    extern function void ma153(int p);
  endclass

  function void Dva153::ma153(int p);
    v_int      = p;            // 1 plain            -> pkg listing
    this.v_this = p;           // 2 `this.` prefix
    super.v_sup = p;           // 3 `super.` prefix
    v_stat     = p;            // 4 static prop, unqualified
    Dva153::v_stat = p;        // 5 static prop, CLASS-scoped
    v_str      = "z";          // 6 a string property
    v_dyn      = new[4];       // 7 dynamic-array `= new[]` LVALUE
    p          = pva153::v_int; // 8 a PACKAGE-scoped read of the pkg variable
  endfunction

endpackage
