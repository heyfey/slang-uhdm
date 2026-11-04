// t39a — CLASS-PROPERTY INITIALIZER shapes.  Each property below is one cell
// of the pass-29 decode: what does Surelog put in the variable's vpiExpr for
// an initializer the emitter's whitelist does not cover?
package p39a;

  class base39;
    int bx;
    function new(int q = 0);
      bx = q;
    endfunction
    static function base39 mk();
      base39 r = new(1);
      return r;
    endfunction
  endclass

  class cls39 #(type T = int);
    static function int sf();
      return 7;
    endfunction
  endclass

  function automatic int pkgf39(int a);
    return a + 1;
  endfunction

  class holder39;
    // A: bare `new` and `new(args)` on a class-typed property.
    base39 a_new       = new;
    base39 a_new_p     = new();
    base39 a_new_arg   = new(3);
    base39 a_new_2arg  = new(3 + 4);
    // B: an UNQUALIFIED call.
    int    b_call      = pkgf39(2);
    static function int lsf39();
      return 9;
    endfunction
    int    b_scall     = lsf39();
    // C: a ::-qualified call.
    base39 c_qcall     = base39::mk();
    int    c_pqcall    = cls39#(int)::sf();
    // D: unbased-unsized / based literals.
    int unsigned d_all = '1;
    int          d_bas = 32'hff;
    // E: a time literal.
    time         e_tim = 9200s;
    // F: a concatenation.
    string       f_cat = {"ab", "cd"};
    // G: an assignment pattern into an assoc array.
    int          g_ap[string] = '{default:0};
    // H: controls that already work.
    int          h_lit = 5;
    int          h_neg = -1;
    string       h_str = "zz";
  endclass

endpackage

module t39a;
  p39a::holder39 h;
  initial h = new();
endmodule
