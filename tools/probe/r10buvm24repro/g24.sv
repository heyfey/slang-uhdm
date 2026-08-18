// r10buvm24repro/g24.sv — THE OMITTED-ARGUMENT GRID.  MEASUREMENT ONLY.
//
// One golden per view; every cell is a CALL with at least one WRITTEN BUT
// EMPTY positional slot (`,,` / a trailing `,` / a leading `,`), against a
// defaulted formal of every literal kind, from every call home, on every
// callee family.  The census keys on the CALL's line:col, so every call sits
// on its own line.
package p24;

  typedef enum int { E0 = 0, E1 = 5, E2 = 9 } e24_t;
  parameter int PAR24 = 7;

  function automatic int help24(int k = 2);
    return k + 1;
  endfunction

  class base24;
    int bx;
    function new(int a = 1, int b = 2, int c = 3);
      bx = a + b + c;
    endfunction
  endclass

  // ---- the DEFAULT-KIND axis: three formals, the MIDDLE one defaulted ----
  function automatic int k_dec  (int a, int    b = 0,        int c = 3); return a + b + c; endfunction
  function automatic int k_dec7 (int a, int    b = 7,        int c = 3); return a + b + c; endfunction
  function automatic int k_sized(int a, int    b = 32'h0,    int c = 3); return a + b + c; endfunction
  function automatic int k_hexff(int a, byte   b = 8'hFF,    int c = 3); return a + int'(b) + c; endfunction
  function automatic int k_neg  (int a, int    b = -1,       int c = 3); return a + b + c; endfunction
  function automatic int k_str  (int a, string b = "",       int c = 3); return a + b.len() + c; endfunction
  function automatic int k_str2 (int a, string b = "zz",     int c = 3); return a + b.len() + c; endfunction
  function automatic int k_bytec(int a, byte   b = ".",      int c = 3); return a + int'(b) + c; endfunction
  function automatic int k_real (int a, real   b = 1.5,      int c = 3); return a + int'(b) + c; endfunction
  function automatic int k_time (int a, time   b = 0,        int c = 3); return a + int'(b) + c; endfunction
  function automatic int k_null (int a, base24 b = null,     int c = 3); return a + ((b == null) ? 0 : 1) + c; endfunction
  function automatic int k_enum (int a, e24_t  b = E1,       int c = 3); return a + int'(b) + c; endfunction
  function automatic int k_par  (int a, int    b = PAR24,    int c = 3); return a + b + c; endfunction
  function automatic int k_expr (int a, int    b = PAR24+1,  int c = 3); return a + b + c; endfunction
  function automatic int k_call (int a, int    b = help24(2),int c = 3); return a + b + c; endfunction
  function automatic int k_bit  (int a, bit    b = 1'b1,     int c = 3); return a + int'(b) + c; endfunction
  function automatic int k_ubit (int a, bit [3:0] b = 4'b1010, int c = 3); return a + int'(b) + c; endfunction

  // ---- the OMISSION-FORM axis: three defaulted formals ----
  function automatic int f3(int a = 1, int b = 2, int c = 3); return a + b + c; endfunction
  task automatic t3(int a = 1, int b = 2, int c = 3); $display("%0d", a + b + c); endtask

  class c24;
    int acc;
    function int mf3(int a = 1, int b = 2, int c = 3); return a + b + c; endfunction
    task mt3(int a = 1, int b = 2, int c = 3); acc = a + b + c; endtask
    function int mstr(int a, string b = "zz", int c = 3); return a + b.len() + c; endfunction

    extern function int oob24();

    function int inbody24();
      int r = 0;
      c24 o = new();
      base24 bh;
      // -- DEFAULT-KIND axis, MIDDLE slot empty, PACKAGE function callee --
      r += k_dec  (1,,4);
      r += k_dec7 (1,,4);
      r += k_sized(1,,4);
      r += k_hexff(1,,4);
      r += k_neg  (1,,4);
      r += k_str  (1,,4);
      r += k_str2 (1,,4);
      r += k_bytec(1,,4);
      r += k_real (1,,4);
      r += k_time (1,,4);
      r += k_null (1,,4);
      r += k_enum (1,,4);
      r += k_par  (1,,4);
      r += k_expr (1,,4);
      r += k_call (1,,4);
      r += k_bit  (1,,4);
      r += k_ubit (1,,4);
      // -- OMISSION-FORM axis on a PACKAGE function --
      r += f3(1,,3);
      r += f3(,2,3);
      r += f3(1,2,);
      r += f3(,,3);
      r += f3(1,,);
      r += f3(,,);
      r += f3(1,2,3);
      r += f3(1);
      r += f3();
      // -- OMISSION-FORM axis on an IN-BODY class method (bare) --
      r += mf3(1,,3);
      r += mf3(,2,3);
      r += mf3(1,2,);
      r += mf3(1,2,3);
      // -- on a class method through a HANDLE --
      r += o.mf3(1,,3);
      r += o.mf3(,2,3);
      r += o.mf3(1,2,);
      r += o.mstr(1,,4);
      // -- on `this` --
      r += this.mf3(1,,3);
      // -- a CONSTRUCTOR call with an empty slot --
      bh = new(1,,3);
      // -- NAMED association with a formal omitted, and a named EMPTY --
      r += f3(.a(1), .c(3));
      r += mf3(.a(1), .c(3));
      // -- a call as an ARGUMENT of another call --
      r += f3(1,, f3(1,,3));
      return r;
    endfunction
    task intask24();
      c24 o2 = new();
      // -- TASK forms (statement position) --
      t3(1,,3);
      t3(1,2,);
      mt3(1,,3);
      o2.mt3(1,,3);
      this.mt3(1,,3);
    endtask
  endclass

  function int c24::oob24();
    int r = 0;
    c24 o = new();
    r += f3(1,,3);
    r += mf3(1,,3);
    r += o.mf3(1,,3);
    r += k_str(1,,4);
    r += k_enum(1,,4);
    r += k_expr(1,,4);
    return r;
  endfunction

  function automatic int pkgcaller24();
    int r = 0;
    c24 o = new();
    r += f3(1,,3);
    r += o.mf3(1,,3);
    r += k_str(1,,4);
    r += k_enum(1,,4);
    r += k_expr(1,,4);
    r += k_call(1,,4);
    return r;
  endfunction

endpackage

module top24;
  import p24::*;

  function automatic int mtop3(int a = 1, int b = 2, int c = 3); return a + b + c; endfunction
  task automatic ttop3(int a = 1, int b = 2, int c = 3); $display("%0d", a + b + c); endtask

  int rr;
  c24 oc;
  initial begin
    oc = new();
    rr  = mtop3(1,,3);
    rr += mtop3(,2,3);
    rr += mtop3(1,2,);
    rr += f3(1,,3);
    rr += k_str(1,,4);
    rr += k_enum(1,,4);
    rr += k_expr(1,,4);
    rr += oc.mf3(1,,3);
    rr += pkgcaller24();
    ttop3(1,,3);
  end

  function automatic int modfn24();
    int r = 0;
    r += mtop3(1,,3);
    r += f3(1,,3);
    r += k_str(1,,4);
    return r;
  endfunction
endmodule
