// v88 b2 — TYPE x CONST cross, in-body vs out-of-body, one package.
package p2;
  typedef enum int { EA=1, EB } e2_t;
  typedef struct packed { int a; int b; } s2_t;
  class handle2; int x; endclass
  const string  c_str = "S";
  const int     c_int = 1;
  const real    c_rl  = 1.5;
  string        v_str = "S";
  int           v_int = 2;
  real          v_rl  = 2.5;
  e2_t          v_enum = EA;
  s2_t          v_st   = '{1,2};
  handle2       v_h;
  bit [7:0]     v_bv  = 8'h5;
  logic         v_lg  = 1'b1;
  int           v_arr[4];
  int           v_dyn[];
  int           v_q[$];
  int           v_aa[string];

  class k2;
    string s; int i; real r; e2_t e; s2_t st; handle2 h; bit [7:0] bv; logic lg;
    function void inb2();
      s = c_str;  i = c_int;  r = c_rl;
      s = v_str;  i = v_int;  r = v_rl;
      e = v_enum; st = v_st;  h = v_h;
      bv = v_bv;  lg = v_lg;
      i = v_arr[0]; i = v_dyn[0]; i = v_q[0]; i = v_aa["k"];
    endfunction
    extern function void oob2();
  endclass
  function void k2::oob2();
    s = c_str;  i = c_int;  r = c_rl;
    s = v_str;  i = v_int;  r = v_rl;
    e = v_enum; st = v_st;  h = v_h;
    bv = v_bv;  lg = v_lg;
    i = v_arr[0]; i = v_dyn[0]; i = v_q[0]; i = v_aa["k"];
  endfunction
endpackage
module topb2;
  p2::k2 h; initial begin h = new(); h.inb2(); end
endmodule
