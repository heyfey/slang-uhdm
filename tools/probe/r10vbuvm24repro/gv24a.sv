// r10vbuvm24repro/gv24a.sv — THE VERIFIER'S OMITTED-ARGUMENT GRID.
// MEASUREMENT ONLY.  Every call sits on its own line (the census keys on
// line:col).  Covers the default SHAPES, the omission FORMS, the callee
// KINDS and the HOMES the brief enumerates, in DEF and ELAB views.
package pv24;

  typedef enum int { V0 = 0, V1 = 5, V2 = 9 } ev24_t;
  parameter int PARV = 7;
  localparam int LPARV = 11;

  function automatic int hv24(int k = 2);
    return k + 1;
  endfunction

  class bv24;
    int bx;
    function new(int a = 1, int b = 2, int c = 3);
      bx = a + b + c;
    endfunction
    virtual function int vm(int a = 1, int b = 2, int c = 3); return a + b + c; endfunction
    static function int sm(int a = 1, int b = 2, int c = 3); return a + b + c; endfunction
  endclass

  class dv24 extends bv24;
    function new(int a = 1, int b = 2, int c = 3);
      super.new(1,,3);
    endfunction
    virtual function int vm(int a = 1, int b = 2, int c = 3); return a + b + c + 1; endfunction
  endclass

  // ---- the DEFAULT-SHAPE axis (middle formal defaulted) ----
  function automatic int d_z  (int a, int      b = 0,           int c = 3); return a + b + c; endfunction
  function automatic int d_one(int a, int      b = 1,           int c = 3); return a + b + c; endfunction
  function automatic int d_42 (int a, int      b = 42,          int c = 3); return a + b + c; endfunction
  function automatic int d_hff(int a, byte     b = 8'hFF,       int c = 3); return a + int'(b) + c; endfunction
  function automatic int d_b10(int a, bit[3:0] b = 4'b1010,     int c = 3); return a + int'(b) + c; endfunction
  function automatic int d_neg(int a, int      b = -1,          int c = 3); return a + b + c; endfunction
  function automatic int d_es (int a, string   b = "",          int c = 3); return a + b.len() + c; endfunction
  function automatic int d_xs (int a, string   b = "x",         int c = 3); return a + b.len() + c; endfunction
  function automatic int d_rl (int a, real     b = 1.5,         int c = 3); return a + int'(b) + c; endfunction
  function automatic int d_nul(int a, bv24     b = null,        int c = 3); return a + ((b == null) ? 0 : 1) + c; endfunction
  function automatic int d_en (int a, ev24_t   b = V1,          int c = 3); return a + int'(b) + c; endfunction
  function automatic int d_par(int a, int      b = PARV,        int c = 3); return a + b + c; endfunction
  function automatic int d_lpr(int a, int      b = LPARV,       int c = 3); return a + b + c; endfunction
  function automatic int d_add(int a, int      b = PARV+LPARV,  int c = 3); return a + b + c; endfunction
  function automatic int d_cal(int a, int      b = hv24(2),     int c = 3); return a + b + c; endfunction
  function automatic int d_cat(int a, int      b = {8'h1,8'h2}, int c = 3); return a + b + c; endfunction
  function automatic int d_tim(int a, time     b = 10ns,        int c = 3); return a + int'(b) + c; endfunction
  function automatic int d_ua (int a, int      b [3] = '{1,2,3},int c = 3); return a + b[0] + c; endfunction

  // ---- the OMISSION-FORM axis ----
  function automatic int g3(int a = 1, int b = 2, int c = 3); return a + b + c; endfunction
  task automatic gt3(int a = 1, int b = 2, int c = 3); $display("%0d", a + b + c); endtask
  function automatic int g4(int a = 1, int b = 2, int c = 3, int d = 4); return a + b + c + d; endfunction

  class cv24;
    int acc;
    function int mf(int a = 1, int b = 2, int c = 3); return a + b + c; endfunction
    task mt(int a = 1, int b = 2, int c = 3); acc = a + b + c; endtask
    extern function int oob();
    function int inbody();
      int r = 0;
      cv24 o = new();
      bv24 bh;
      bv24 vh;
      dv24 dh;
      // DEFAULT-SHAPE axis
      r += d_z  (1,,4);
      r += d_one(1,,4);
      r += d_42 (1,,4);
      r += d_hff(1,,4);
      r += d_b10(1,,4);
      r += d_neg(1,,4);
      r += d_es (1,,4);
      r += d_xs (1,,4);
      r += d_rl (1,,4);
      r += d_nul(1,,4);
      r += d_en (1,,4);
      r += d_par(1,,4);
      r += d_lpr(1,,4);
      r += d_add(1,,4);
      r += d_cal(1,,4);
      r += d_cat(1,,4);
      r += d_tim(1,,4);
      r += d_ua (1,,4);
      // OMISSION FORMS on a package function
      r += g3(1,,3);
      r += g3(,2,3);
      r += g3(1,2,);
      r += g3(,,3);
      r += g3(1,,);
      r += g3(,,);
      r += g3(1,2,3);
      r += g3(1);
      r += g3();
      r += g4(1,,,4);
      r += g4(,,,);
      // NAMED forms
      r += g3(.a(1), .c(3));
      r += g3(.a(1), .b(2), .c(3));
      // POSITIONAL then NAMED, with an empty positional slot
      r += g3(1, , .c(3));
      r += g3(1, 2, .c(3));
      // class method: bare in-body, handle, this, STATIC, VIRTUAL through base
      r += mf(1,,3);
      r += o.mf(1,,3);
      r += this.mf(1,,3);
      r += bv24::sm(1,,3);
      dh = new(1,,3);
      vh = dh;
      r += vh.vm(1,,3);
      // constructor
      bh = new(1,,3);
      // nested call as an argument
      r += g3(1,, g3(1,,3));
      return r;
    endfunction
    task intask();
      cv24 o2 = new();
      gt3(1,,3);
      gt3(1,2,);
      mt(1,,3);
      o2.mt(1,,3);
      this.mt(1,,3);
    endtask
  endclass

  function int cv24::oob();
    int r = 0;
    cv24 o = new();
    r += g3(1,,3);
    r += mf(1,,3);
    r += o.mf(1,,3);
    r += d_es(1,,4);
    r += d_en(1,,4);
    r += d_add(1,,4);
    return r;
  endfunction

  function automatic int pkgcall();
    int r = 0;
    cv24 o = new();
    r += g3(1,,3);
    r += o.mf(1,,3);
    r += d_cal(1,,4);
    return r;
  endfunction

  task automatic pkgtask();
    gt3(1,,3);
  endtask

endpackage

interface iv24;
  function automatic int ifn(int a = 1, int b = 2, int c = 3); return a + b + c; endfunction
  task automatic itk(int a = 1, int b = 2, int c = 3); $display("%0d", a + b + c); endtask
endinterface

module inner24 #(parameter int ID = 0) ();
  import pv24::*;
  int q;
  function automatic int mfn(int a = 1, int b = 2, int c = 3); return a + b + c; endfunction
  initial begin
    q  = mfn(1,,3);
    q += g3(1,,3);
    q += d_en(1,,4);
  end
  always @* begin
    q = mfn(1,,3);
  end
endmodule

program pv24prog;
  import pv24::*;
  int pr;
  initial begin
    pr  = g3(1,,3);
    pr += d_xs(1,,4);
  end
endprogram

module topv24;
  import pv24::*;
  iv24 ifc();
  inner24 #(.ID(0)) i0 ();
  inner24 #(.ID(1)) i1 ();
  inner24 #(.ID(2)) i2 ();
  pv24prog pg();

  function automatic int mtop(int a = 1, int b = 2, int c = 3); return a + b + c; endfunction
  task automatic ttop(int a = 1, int b = 2, int c = 3); $display("%0d", a + b + c); endtask

  int rr;
  cv24 oc;
  genvar gi;
  generate
    for (gi = 0; gi < 2; gi++) begin : gblk
      int gv;
      initial begin
        gv  = mtop(1,,3);
        gv += g3(1,,3);
      end
    end
  endgenerate

  initial begin
    oc = new();
    rr  = mtop(1,,3);
    rr += mtop(,2,3);
    rr += mtop(1,2,);
    rr += g3(1,,3);
    rr += d_es(1,,4);
    rr += oc.mf(1,,3);
    rr += pkgcall();
    rr += ifc.ifn(1,,3);
    ttop(1,,3);
    ifc.itk(1,,3);
    pkgtask();
  end

  always @* begin
    rr = mtop(1,,3);
  end

  function automatic int modfn();
    int r = 0;
    r += mtop(1,,3);
    r += g3(1,,3);
    return r;
  endfunction
endmodule
