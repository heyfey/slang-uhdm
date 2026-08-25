// r10uvm141 VERIFIER arm E -- BODY-LOCAL SHAPES the implementer's grid did not
// reach: a STATIC body local, a local inside fork/join, a local shadowing a
// class property, a struct local, an unpacked-array local, a CLASS-HANDLE
// local, a QUEUE local (the shape R0 names), a void function, a task with an
// output formal, and a local whose value feeds $bits.
package p141e;

  typedef struct packed { int hi; int lo; } pair_e;

  class ea1;                       // STATIC body local under qualifier+lifetime
    local function automatic int f1(int a);
      static int sr = 0;
      sr = sr + a;
      return sr;
    endfunction
  endclass

  class ea2;                       // local inside fork/join_none
    protected task automatic t2(int a);
      int outer;
      outer = a;
      fork
        begin
          int inner;
          inner = outer;
          $display("%0d", inner);
        end
      join_none
    endtask
  endclass

  class ea3;                       // body local SHADOWS a class property
    int shadow;
    local function automatic int f3(int a);
      int shadow;
      shadow = a;
      return shadow;
    endfunction
  endclass

  class ea4;                       // struct + unpacked-array locals
    virtual function automatic int f4(int a);
      pair_e ps;
      int arr [0:3];
      ps.hi = a; ps.lo = a;
      arr[0] = ps.hi;
      return arr[0] + ps.lo;
    endfunction
  endclass

  class ea5h;
    int v;
  endclass
  class ea5;                       // CLASS-HANDLE local + QUEUE local (R0 shape)
    static function automatic int f5(int a);
      ea5h h;
      int q[$];
      h = new();
      h.v = a;
      q.push_back(h.v);
      return q[0];
    endfunction
  endclass

  class ea6;                       // void function with a local
    local function automatic void f6(int a);
      int r6;
      r6 = a;
      $display("%0d", r6);
    endfunction
  endclass

  class ea7;                       // task with an OUTPUT formal + a local
    protected task automatic t7(input int a, output int o);
      int tmp;
      tmp = a + 1;
      o = tmp;
    endtask
  endclass

  class ea8;                       // local feeding $bits (the fvarsAll71 reader)
    local function automatic int f8(int a);
      pair_e wide;
      wide.hi = a;
      return $bits(wide) + wide.lo;
    endfunction
  endclass

  // ---- one-feature controls in their own classes ------------------------
  class eb1;                       // lifetime only
    function automatic int g1(int a);
      static int sg = 0;
      sg = sg + a;
      return sg;
    endfunction
  endclass
  class eb2;                       // qualifier only
    local function int g2(int a);
      int q[$];
      q.push_back(a);
      return q[0];
    endfunction
  endclass

endpackage

module t141e;
  initial begin
    p141e::ea1 h1; p141e::ea2 h2; p141e::ea3 h3; p141e::ea4 h4;
    p141e::ea5 h5; p141e::ea6 h6; p141e::ea7 h7; p141e::ea8 h8;
    p141e::eb1 k1; p141e::eb2 k2;
    h1 = new(); h2 = new(); h3 = new(); h4 = new();
    h5 = new(); h6 = new(); h7 = new(); h8 = new();
    k1 = new(); k2 = new();
  end
endmodule
