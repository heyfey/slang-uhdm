// r10v161 ARM B — THE POPULATION.  Every static-local FACE and its automatic
// twin, read from an IMMEDIATE ASSERTION CONDITION at control depth 0 in an
// IN-BODY class method, beside a MIRROR read from an `if` CONDITION — the
// column our emitter was already right on.  Golden's two columns must agree,
// and the patched binary must reproduce golden on both.
// MEASUREMENT ONLY.  LHS is always golden (Surelog), RHS is always ours.
package pk_b161;
  int pkg_var_b = 3;
  parameter int PK_B = 7;
  typedef enum bit [1:0] {EB0, EB1, EB2} eb_t;
endpackage

class Held_b161;
  int f = 5;
endclass

class Base_b161;
  int inh_prop = 1;
  static int inh_static = 2;
endclass

class Faces_b161 extends Base_b161;
  int prop = 1;
  static int sprop = 2;
  const int cprop = 3;
  Held_b161 hprop;
  int aprop[4];
  int qprop[$];
  pk_b161::eb_t eprop;
  localparam int LP_B = 9;
  int shadow;

  // ---- static-local faces read from an ASSERTION CONDITION --------------
  function void b_chandle();
    static chandle s_ch;
    chandle a_ch;
    static chandle s_ch_unwritten;
    s_ch = null;
    if (s_ch == null) prop = 1;                       // b01 if-column
    assert (s_ch == null);                            // b02 assert-column
    assert (a_ch == null);                            // b03 automatic twin
    assert (s_ch_unwritten == null);                  // b04 unwritten twin
  endfunction

  function void b_int();
    static int s_i = 0;
    static int s_j;
    int a_i;
    if (s_i > 0) prop = 1;                            // b05
    assert (s_i > 0);                                 // b06
    assert (s_j > 0);                                 // b07 no initializer
    assert (a_i > 0);                                 // b08 automatic twin
    assume (s_i > 1);                                 // b09
    cover  (s_i > 2);                                 // b10
    assert #0 (s_i > 3);                              // b11 deferred
    assert final (s_i > 4);                           // b12 final
  endfunction

  function void b_string();
    static string s_s = "x";
    string a_s;
    if (s_s == "x") prop = 1;                         // b13
    assert (s_s == "x");                              // b14
    assert (a_s == "y");                              // b15
  endfunction

  function void b_handle();
    static Held_b161 s_h;
    Held_b161 a_h;
    if (s_h != null) prop = 1;                        // b16
    assert (s_h != null);                             // b17
    assert (a_h != null);                             // b18
  endfunction

  function void b_queue();
    static int s_q[$];
    int a_q[$];
    if (s_q.size() > 0) prop = 1;                     // b19
    assert (s_q.size() > 0);                          // b20
    assert (a_q.size() > 0);                          // b21
  endfunction

  function void b_array();
    static int s_arr[4];
    int a_arr[4];
    if (s_arr[0] > 0) prop = 1;                       // b22
    assert (s_arr[0] > 0);                            // b23
    assert (a_arr[1] > 0);                            // b24
  endfunction

  function void b_two_statics();
    static int s_p = 1;
    static int s_q2 = 2;
    assert (s_p < s_q2);                              // b25 two in one assert
  endfunction

  function void b_shadow();
    static int shadow = 11;
    assert (shadow == 11);                            // b26 shadows a property
  endfunction

  task b_task();
    static int s_tk = 12;
    int a_tk;
    if (s_tk > 0) prop = 1;                           // b27
    assert (s_tk > 0);                                // b28 in a TASK
    assert (a_tk > 0);                                // b29
  endtask

  static function int b_static_method(int formal_sm);
    static int s_sm = 9;
    if (s_sm > 0) sprop = 1;                          // b30
    assert (s_sm > 0);                                // b31 in a STATIC method
    assert (formal_sm > 0);                           // b32 its FORMAL
    return s_sm;
  endfunction

  function new();
    static int s_ctor = 8;
    assert (s_ctor == 8);                             // b33 in a CONSTRUCTOR
  endfunction

  virtual function void b_virtual(int formal_v);
    static int s_v = 1;
    if (formal_v > 0) prop = 1;                       // b34
    assert (s_v > 0);                                 // b35 in a VIRTUAL method
    assert (formal_v > 0);                            // b36 its FORMAL
  endfunction

  function void b_nested_begin();
    begin
      static int s_nb = 4;
      assert (s_nb == 4);                             // b37 plain begin, d0
    end
  endfunction

  function void b_named_begin();
    begin : nb_b161
      static int s_named = 5;
      assert (s_named == 5);                          // b38 NAMED begin, d0
    end
  endfunction

  task b_fork();
    static int s_fk_outer = 6;
    fork
      begin
        static int s_fk = 6;
        assert (s_fk == 6);                           // b39 in a FORK arm
        assert (s_fk_outer == 6);                     // b40 outer static
      end
    join_none
  endtask

  function void b_loop_body();
    static int s_out = 1;
    for (int k = 0; k < 2; k++) begin
      static int s_lb = 7;
      assert (s_lb == 7);                             // b41 in a LOOP body (bare)
      assert (s_out == 1);                            // b42 (bare)
    end
  endfunction

  extern function void b_oob();

  function void b_action_blocks();
    static int s_ab = 1;
    assert (s_ab == 1) prop = s_ab;  else prop = s_ab; // b43 cond / b44 pass / b45 else
  endfunction

  function void b_deeper();
    static int s_d = 1;
    if (prop > 0) begin
      assert (s_d == 1);                              // b46 ONE control body deeper
    end
  endfunction
endclass

function void Faces_b161::b_oob();
  static int s_oob = 13;
  int a_oob;
  assert (s_oob == 13);                               // b47 OUT-OF-BODY method
  assert (a_oob == 0);                                // b48
endfunction

class GenB161 #(type T = int, int W = 1);
  T gp;
  function void b_gen(T formal_g);
    static T s_gen;
    static int s_w = W;
    assert (s_w != 0);                                // b49
    assert (formal_g != gp);                          // b50 formal in a generic
  endfunction
endclass

package pk_b2_161;
  function automatic int pkg_fn_b(int q);
    static int s_in_pkg_fn = 0;
    assert (s_in_pkg_fn >= 0);                        // b51 PACKAGE function
    assert (q > 0);                                   // b52 its formal
    return s_in_pkg_fn + q;
  endfunction
endpackage

module top_b161;
  Faces_b161 fb;
  GenB161 #(int, 1) gb1;
  GenB161 #(bit, 2) gb2;
  GenB161 #() gb0;
  int mv;

  function automatic int mod_fn_b(int q);
    static int s_mod = 0;
    assert (s_mod >= 0);                              // b53 MODULE function
    assert (q > 0);                                   // b54 its formal
    return s_mod + q;
  endfunction

  initial begin
    static int s_init = 14;
    assert (s_init == 14);                            // b55 module initial
    fb = new();
    mv = mod_fn_b(1) + pk_b2_161::pkg_fn_b(2);
  end
endmodule
