// r10v194 arm B — THE EMISSION FACES the r10uvm194 grid does not carry, all in
// an OUT-OF-BODY class method (the law's own home) so the exemption is live in
// every cell:
//
//   b_read    a pure READ of the return name before the select write
//   b_rec     RECURSION with a bit-select on a packed return
//   b_memb    a MEMBER select on a packed-struct return
//   b_unp     an ELEMENT select on an UNPACKED-array return
//   b_nest    the select in an INNER named block, the whole refs OUTSIDE it
//   b_two_st  a select on a DIFFERENT variable first, the return name second
//   b_void    a VOID function and
//   b_task    a TASK — neither may gain a return object of any kind
//
// LHS is ALWAYS golden.
package vb194_src;
  typedef struct packed { bit [7:0] hi; bit [7:0] lo; } vb_st;
  typedef byte vb_arr [0:3];

  class VB194;
    extern function string     b_read();
    extern function bit [15:0] b_rec(input int n);
    extern function vb_st      b_memb();
    extern function vb_arr     b_unp();
    extern function string     b_nest();
    extern function string     b_two_st();
    extern function void       b_void();
    extern task                b_task();
  endclass

  // READ of the return name, then the select WRITE.
  function string VB194::b_read();
    int i; string t;
    i = 0;
    t = b_read;
    b_read = {t," "};
    b_read[i] = 8'h41;
  endfunction

  // RECURSION + bit-select on a PACKED return.
  function bit [15:0] VB194::b_rec(input int n);
    b_rec = 16'h0;
    b_rec[0] = 1'b1;
    if (n > 0)
      b_rec = b_rec | b_rec(n-1);
  endfunction

  // MEMBER select on a packed-struct return.
  function vb_st VB194::b_memb();
    b_memb = '{default:0};
    b_memb.hi = 8'h41;
  endfunction

  // ELEMENT select on an UNPACKED-array return.
  function vb_arr VB194::b_unp();
    int i; i = 1;
    b_unp = '{default:0};
    b_unp[i] = 8'h42;
  endfunction

  // The select lives in an INNER named block; the whole refs are OUTSIDE it,
  // so endSelTrack's chain law must NOT re-point them and golden's `uhdmbegin`
  // scan of the OUTER block's own Stmts() must not answer either.
  function string VB194::b_nest();
    int i; i=0;
    b_nest = {b_nest," "};
    begin : inner
      b_nest[i] = 8'h43;
    end
  endfunction

  // A select on a DIFFERENT variable is the block's FIRST select; the return
  // name's select is the second statement.
  function string VB194::b_two_st();
    int i; string t;
    i=0; t = "xy";
    t[i] = 8'h44;
    b_two_st = {b_two_st,t};
    b_two_st[i] = 8'h45;
  endfunction

  // A VOID function: no return variable exists, so no reference may gain one.
  function void VB194::b_void();
    string t; int i;
    i=0; t = "zz";
    t[i] = 8'h46;
  endfunction

  // A TASK: same assertion.
  task VB194::b_task();
    string t; int i;
    i=0; t = "ww";
    t[i] = 8'h47;
  endtask
endpackage

module vb194_top;
  import vb194_src::*;
  VB194 h;
  string s1, s5, s6;
  bit [15:0] v2;
  vb_st v3;
  vb_arr v4;
  initial begin
    h = new();
    s1 = h.b_read();
    v2 = h.b_rec(2);
    v3 = h.b_memb();
    v4 = h.b_unp();
    s5 = h.b_nest();
    s6 = h.b_two_st();
    h.b_void();
    h.b_task();
  end
endmodule
