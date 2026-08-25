// r10uvm141 VERIFIER arm F -- DEFINITION STYLES x QUALIFIERS x COLLISIONS x
// INSTANCE COUNTS: extern prototype + out-of-body definition (lifetime on
// EITHER half), pure virtual, an out-of-body definition written with the
// class scope, names colliding with a system function and with a package free
// function, a parameterized class with THREE specializations, and 1 vs 3
// instances of the same class.
package p141f;

  function automatic int unsigned ceil(int unsigned a, int unsigned b);
    // a PACKAGE FREE FUNCTION with the same name as the class method below
    return (a + b - 1) / b;
  endfunction

  class fa_inbody;                 // affected, in-body, name collides with the
    local function automatic int unsigned ceil(int unsigned a,   // package fn
                                               int unsigned b);
      int unsigned r = a / b;
      int unsigned r0 = a % b;
      return r0 ? (r + 1) : r;
    endfunction
    function int unsigned useit(); return ceil(7, 2); endfunction   // REFERENCED
  endclass

  class fa_unref;                  // affected, in-body, NEVER referenced
    protected function automatic int clog2(int a);   // system-function spelling
      int rr = a;
      return rr;
    endfunction
  endclass

  class fb_extdef;                 // extern prototype WITH qualifier; the
    extern local function int e1(int a);           // lifetime on the DEFINITION
  endclass
  function automatic int fb_extdef::e1(int a);
    int re = a;
    return re;
  endfunction

  class fb_extdef2;                // extern prototype, NO lifetime anywhere
    extern protected function int e2(int a);
  endclass
  function int fb_extdef2::e2(int a);
    int re2 = a;
    return re2;
  endfunction

  virtual class fc_pure;           // pure virtual (no body at all)
    pure virtual function int pv(int a);
  endclass
  class fc_impl extends fc_pure;
    virtual function automatic int pv(int a);     // affected override
      int rp = a;
      return rp;
    endfunction
  endclass

  class fd_param #(int W = 8);     // THREE specializations of one class
    local function automatic int fw(int a);
      int rw = a + W;
      return rw;
    endfunction
    function int useit(); return fw(W); endfunction
  endclass

  class fe_three;                  // instantiated THREE times below
    static function automatic int f3(int a);
      int r3 = a;
      return r3;
    endfunction
  endclass

  // ---- controls -----------------------------------------------------------
  class fg_ctl;                    // qualifier only, referenced
    local function int g(int a);
      int rg = a;
      return rg;
    endfunction
    function int useit(); return g(1); endfunction
  endclass

endpackage

module t141f;
  p141f::fd_param #(4)  s4;
  p141f::fd_param #(8)  s8;
  p141f::fd_param #(16) s16;
  initial begin
    p141f::fa_inbody h1; p141f::fa_unref h2;
    p141f::fb_extdef h3; p141f::fb_extdef2 h4; p141f::fc_impl h5;
    p141f::fe_three t1, t2, t3;
    p141f::fg_ctl hc;
    h1 = new(); h2 = new(); h3 = new(); h4 = new(); h5 = new();
    t1 = new(); t2 = new(); t3 = new(); hc = new();
    s4 = new(); s8 = new(); s16 = new();
    $display("%0d %0d", h1.useit(), p141f::ceil(7, 2));
    $display("%0d %0d %0d", s4.useit(), s8.useit(), s16.useit());
  end
endmodule
