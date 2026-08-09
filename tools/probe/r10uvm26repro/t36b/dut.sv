package pk2;
  typedef enum {PA, PB} pe_t;
  typedef int pi_t;
endpackage

package pk1;
  import pk2::*;

  class base_c;
    int x;
    function new(int a = 0);
      x = a;
    endfunction
    static function base_c get();
      base_c r = new(1);
      return r;
    endfunction
  endclass

  typedef enum {EA, EB} le_t;
  typedef int li_t;
  typedef logic [3:0] lv_t;
  typedef struct packed { logic a; logic b; } ls_t;
  typedef string ls2_t;

  // class-typed, the new()-with-args arm
  base_c c_newargs = new(3);
  base_c c_null    = null;
  var base_c c_var;
  base_c c_plain;

  // identifier-typed non-class locals
  le_t  e_td;
  li_t  i_td;
  lv_t  v_td;
  ls_t  s_td;
  ls2_t st_td;
  li_t  i_td_init = 4;
  const li_t i_td_const = 5;

  // package-qualified identifier types
  pe_t  e_pk;
  pi_t  i_pk;

  // inline (keyword-spelled) aggregate types
  enum {IA, IB} e_inline;
  struct packed { logic a; logic b; } s_inline;
  logic [3:0] v_kw;
  int i_kw;
endpackage

module top;
  initial begin
    if (pk1::c_plain == null) $display("x");
  end
endmodule
