package pk1;
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

  base_c c_new = new();
  base_c c_plain;
  const base_c c_const = base_c::get();
  le_t  e_td;
  enum {IA, IB} e_inline;
  int   i_kw;
endpackage

// The importing PACKAGE (clone path) ...
package pk2;
  import pk1::*;
  int own_v = 1;
endpackage

// ... and the importing MODULE (module hoist path).
module top;
  import pk1::*;
  int m_own = 2;
  initial begin
    if (c_plain == null) $display("x");
  end
endmodule
