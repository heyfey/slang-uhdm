// r10uvm141 arm A -- DOES GOLDEN'S QUALIFIER+LIFETIME STUB CARRY vpiVariables?
//
// LAW qualifiedLifetimeMethodLosesNamePortsBody46 already models the object:
// a class method written with a QUALIFIER *and* a written LIFETIME comes out
// of Surelog's CompileClass::compile_class_method_ with an invalid body node,
// so it loses its NAME, its Tf_port_list and its body.  What pass 46 never
// asked is whether the BODY LOCALS survive on the stub's vpiVariables vector,
// and that vector is the whole remaining BuildUVMPkg head (uvm_pkg.sv:75228
// `local function automatic int unsigned ceil(...)`, whose `int r`/`int r0`
// we list and golden may not).
//
// ONE affected method per class, so nothing collapses (pass 46 measured that
// several in one class fuse into one object); the controls sit in their own
// classes too so the two populations are never confused.
package p141a;

  // ---- affected candidates: qualifier x written lifetime -----------------
  class ca1;                       // the exact uvm_reg_map::ceil spelling
    local function automatic int unsigned f1(int unsigned a, int unsigned b);
      int r = a / b;
      int r0 = a % b;
      return r0 ? (r+1) : r;
    endfunction
  endclass

  class ca2;                       // same shape, NO body locals at all
    local function automatic int f2(int a);
      return a + 1;
    endfunction
  endclass

  class ca3;                       // protected + automatic (slang rejects a
                                   // written `static` lifetime on a class
                                   // method, so that cell is unreachable here)
    protected function automatic int f3(int a);
      int q = a;
      return q;
    endfunction
  endclass

  class ca4;                       // virtual + automatic
    virtual function automatic int f4(int a);
      int q = a;
      return q;
    endfunction
  endclass

  class ca5;                       // class-item static + automatic
    static function automatic int f5(int a);
      int q = a;
      return q;
    endfunction
  endclass

  class ca6;                       // a TASK (no return type)
    local task automatic t6(int a);
      int q = a;
      $display("%0d", q);
    endtask
  endclass

  class ca7;                       // affected method with a NAMED begin block
    local function automatic int f7(int a);
      int top;
      begin : blk
        int inner;
        inner = a;
        top = inner;
      end
      return top;
    endfunction
  endclass

  class ca8;                       // affected method, locals but NO initialiser
    local function automatic int f8(int a);
      int u;
      int v;
      u = a; v = u;
      return v;
    endfunction
  endclass

  // ---- controls: exactly ONE of the two features ------------------------
  class cb1;                       // lifetime only, no qualifier
    function automatic int g1(int a);
      int q = a;
      return q;
    endfunction
  endclass

  class cb2;                       // qualifier only, no written lifetime
    local function int g2(int a);
      int q = a;
      return q;
    endfunction
  endclass

  class cb3;                       // neither
    function int g3(int a);
      int q = a;
      return q;
    endfunction
  endclass

endpackage

module t141a;
  initial begin
    p141a::ca1 h1; p141a::ca2 h2; p141a::ca3 h3; p141a::ca4 h4;
    p141a::ca6 h6; p141a::ca7 h7; p141a::ca8 h8;
    p141a::cb1 k1; p141a::cb2 k2; p141a::cb3 k3;
    h1 = new(); h2 = new(); h3 = new(); h4 = new();
    h6 = new(); h7 = new(); h8 = new();
    k1 = new(); k2 = new(); k3 = new();
  end
endmodule
