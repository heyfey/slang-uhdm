// r10v161 ARM A — THE STATIC-LOCAL FACE MATRIX, read OUTSIDE any window.
// MEASUREMENT ONLY.  Every cell here is a MUST-STAY control: none of these
// reads sits in an immediate-assertion condition or a case-item expression,
// so § assertCondIsAClassMethodWindow161 must not move a single one.
// LHS is always golden (Surelog), RHS is always ours.
package pk_a161;
  int pkg_var_a = 3;
  parameter int PK_A = 7;
  typedef enum bit [1:0] {EA0, EA1, EA2} ea_t;

  function automatic int pkg_fn_a(int q);
    static int s_in_pkg_fn = 0;      // a static in a PACKAGE function
    s_in_pkg_fn = s_in_pkg_fn + q;
    return s_in_pkg_fn;
  endfunction
endpackage

class Base_a161;
  int inherited_prop = 1;
  static int inherited_static = 2;
endclass

class Held_a161;
  int f = 5;
endclass

class Faces_a161 extends Base_a161;
  int prop = 1;
  static int sprop = 2;
  const int cprop = 3;
  Held_a161 hprop;
  int aprop[4];
  int qprop[$];
  pk_a161::ea_t eprop;
  localparam int LP_A = 9;
  int shadow;                       // shadowed by a static local below

  // ---- ordinary reads of every static-local FACE ------------------------
  function void f_chandle();
    static chandle s_ch;            // static CHANDLE
    chandle a_ch;                   // automatic twin
    static chandle s_ch_unwritten;  // never written
    s_ch = null;
    a_ch = s_ch;
    if (s_ch_unwritten == null) prop = prop + 1;
    prop = (a_ch == null) ? 1 : 2;
  endfunction

  function void f_int();
    static int s_i = 0;             // static WITH INITIALIZER
    static int s_j;                 // static, no initializer
    int a_i;                        // automatic twin
    s_i = s_i + 1;                  // read before written on the RHS
    s_j = s_i;
    a_i = s_j;
    prop = a_i;
  endfunction

  function void f_string();
    static string s_s = "x";
    string a_s;
    a_s = s_s;
    prop = a_s.len();
  endfunction

  function void f_handle();
    static Held_a161 s_h;
    Held_a161 a_h;
    s_h = new();
    a_h = s_h;
    prop = a_h.f;
  endfunction

  function void f_queue();
    static int s_q[$];
    int a_q[$];
    s_q.push_back(1);
    a_q = s_q;
    prop = a_q.size();
  endfunction

  function void f_array();
    static int s_arr[4];
    int a_arr[4];
    s_arr[0] = 1;
    a_arr = s_arr;
    prop = a_arr[0];
  endfunction

  function void f_event();
    static event s_ev;
    event a_ev;
    a_ev = s_ev;
    prop = 1;
  endfunction

  function void f_two_statics();
    static int s_p = 1;
    static int s_q2 = 2;
    prop = s_p + s_q2;
  endfunction

  function void f_nested_begin();
    begin
      static int s_nb = 4;
      prop = s_nb;
    end
  endfunction

  function void f_named_begin();
    begin : nb_a161
      static int s_named = 5;
      prop = s_named;
    end
  endfunction

  task t_fork();
    fork
      begin
        static int s_fk = 6;
        prop = s_fk;
      end
    join_none
  endtask

  function void f_loop_body();
    for (int k = 0; k < 2; k++) begin
      static int s_lb = 7;
      prop = s_lb + k;
    end
  endfunction

  function new();
    static int s_ctor = 8;
    prop = s_ctor;
  endfunction

  static function int f_static_method();
    static int s_sm = 9;
    return s_sm + sprop;
  endfunction

  function void f_shadow();
    static int shadow = 11;         // shadows the class property `shadow`
    prop = shadow;
  endfunction

  task t_task();
    static int s_tk = 12;
    prop = s_tk;
  endtask

  extern function void f_oob();

  function void f_reads_props();
    // every BARE face, read outside a window
    prop = prop + sprop + cprop + inherited_prop + inherited_static + LP_A;
    prop = prop + pk_a161::pkg_var_a + pk_a161::PK_A + int'(eprop) + aprop[0];
    prop = prop + qprop.size() + this.prop;
    if (hprop != null) prop = prop + hprop.f;
  endfunction
endclass

function void Faces_a161::f_oob();
  static int s_oob = 13;            // a static in an OUT-OF-BODY method
  int a_oob;
  a_oob = s_oob;
  prop = a_oob;
endfunction

class Gen_a161 #(type T = int, int W = 1);
  T gp;
  function void f_gen();
    static T s_gen;
    static int s_w = W;
    T a_gen;
    a_gen = s_gen;
    gp = a_gen;
    if (s_w != 0) gp = a_gen;
  endfunction
endclass

module top_a161;
  Faces_a161 fa;
  Gen_a161 #(int, 1) g1;            // specialization 1
  Gen_a161 #(bit, 2) g2;            // specialization 2
  Gen_a161 #() g0;                  // the DEFAULT specialization
  int mv;

  function automatic int mod_fn_a(int q);
    static int s_mod = 0;           // a static in a MODULE function
    s_mod = s_mod + q;
    return s_mod;
  endfunction

  initial begin
    static int s_init = 14;         // a static in an initial block
    fa = new();
    mv = s_init + mod_fn_a(1) + pk_a161::pkg_fn_a(2);
  end
endmodule
