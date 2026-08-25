// r10uvm141 arm B -- DEFINITION STYLES x OWNERS for the qualifier+lifetime stub.
//
// LAW qualLifetimeStubListsNoBodyLocals141 rides on pass 46's predicate, which
// EXCLUDES extern prototypes and out-of-body definitions (a different Surelog
// entry point).  This arm measures those excluded styles anyway, so the
// exclusion is a MEASURED boundary and not an assumption, and adds the owners
// the corpus does not have (class in a MODULE, NESTED class, class at
// compilation-unit scope) plus the multi-method COLLAPSE pass 46 recorded but
// did not implement.
class cu141;                                   // COMPILATION-UNIT owner
  local function automatic int u1(int a);
    int q = a;
    return q;
  endfunction
endclass

package p141b;

  virtual class cb_pure;                       // control: no body at all
    pure virtual function int pv1(int a);
  endclass

  // Surelog's grammar REJECTS a lifetime on an extern prototype
  // ("extern local function automatic": PA0207), so the only reachable
  // out-of-body cell writes the qualifier on the prototype and the lifetime
  // on the DEFINITION.
  class cb_ext2;                               // prototype WITHOUT the lifetime,
    extern local function int e2(int a);       // definition WITH it
  endclass
  function automatic int cb_ext2::e2(int a);
    int q = a;
    return q;
  endfunction

  class cb_multi;                              // THREE affected methods -> pass 46
    local function automatic int m1(int a);    // measured a COLLAPSE onto one
      int q = a;                               // object; nothing in either corpus
      return q;                                // has this shape.
    endfunction
    protected function automatic int m2(int a);
      int w = a;
      return w;
    endfunction
    local task automatic m3(int a);
      int z = a;
      $display("%0d", z);
    endtask
  endclass

  class cb_outer;                              // NESTED class owner
    class cb_inner;
      local function automatic int n1(int a);
        int q = a;
        return q;
      endfunction
    endclass
    local function automatic int o1(int a);
      int q = a;
      return q;
    endfunction
  endclass

endpackage

module t141b;
  class cm1;                                   // MODULE-owned class
    local function automatic int q1(int a);
      int q = a;
      return q;
    endfunction
    function int caller(int a);                // REFERENCED: q1 is called
      return q1(a);
    endfunction
  endclass
  class cm2;                                   // UNREFERENCED twin
    local function automatic int q2(int a);
      int q = a;
      return q;
    endfunction
  endclass
  initial begin
    cm1 a1; cm2 a2; cu141 a3;
    p141b::cb_ext2 b2; p141b::cb_multi b3;
    p141b::cb_outer b4; p141b::cb_outer::cb_inner b5;
    a1 = new(); a2 = new(); a3 = new();
    b2 = new(); b3 = new(); b4 = new(); b5 = new();
    $display("%0d", a1.caller(7));
  end
endmodule
