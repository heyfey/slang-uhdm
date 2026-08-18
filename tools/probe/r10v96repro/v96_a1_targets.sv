// r10v96 arm 1 — EVERY cast target keyword, one carrier ($display arg), one home.
package v96p1;
  typedef enum bit [1:0] { E0, E1 } e_t;
  typedef struct packed { bit [3:0] a; bit [3:0] b; } s_t;
  typedef union packed { bit [7:0] u; s_t v; } u_t;
  typedef logic [7:0] lv_t;
  typedef int          ti_t;
  typedef integer      tg_t;
  typedef longint      tl_t;
  typedef shortint     ts_t;
  typedef byte         tb_t;
  typedef bit          tbit_t;
  typedef real         tr_t;
  typedef shortreal    tsr_t;
  typedef time         tt_t;
  typedef string       tstr_t;
  class C1; int f; endclass
  class C2 #(parameter int W = 4); bit [W-1:0] g; endclass
  parameter int PW = 6;

  function automatic void f1();
    logic [15:0] q = 16'h00ab;
    real         r = 1.5;
    $display("%0d", real'(q));
    $display("%0d", shortreal'(q));
    $display("%0d", realtime'(q));
    $display("%0d", time'(q));
    $display("%0d", int'(q));
    $display("%0d", integer'(q));
    $display("%0d", longint'(q));
    $display("%0d", shortint'(q));
    $display("%0d", byte'(q));
    $display("%0d", bit'(q));
    $display("%0d", logic'(q));
    $display("%0d", reg'(q));
    $display("%0d", 9'(q));
    $display("%0d", 1'(q));
    $display("%0d", PW'(q));
    $display("%0d", e_t'(q));
    $display("%0d", s_t'(q));
    $display("%0d", u_t'(q));
    $display("%0d", lv_t'(q));
    $display("%0d", ti_t'(q));
    $display("%0d", tg_t'(q));
    $display("%0d", tl_t'(q));
    $display("%0d", ts_t'(q));
    $display("%0d", tb_t'(q));
    $display("%0d", tbit_t'(q));
    $display("%0d", tr_t'(q));
    $display("%0d", tsr_t'(q));
    $display("%0d", tt_t'(q));
    $display("%0d", int'(r));
  endfunction
endpackage
