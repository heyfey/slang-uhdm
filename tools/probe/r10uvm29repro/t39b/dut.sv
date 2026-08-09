// t39b — the cells t39a left open: BASED literals at widths above/below the
// property, a ::-qualified call WITH arguments (the `uvm_register_cb` shape),
// a PACKAGE-qualified call, and `new` on a derived/parameterised class.
package q39b;
  function automatic int qf39(int a);
    return a;
  endfunction
  class kb39 #(int W = 4);
    static function int sf(int a, string b);
      return a;
    endfunction
  endclass
  class bb39;
    function new(int q = 0);
    endfunction
  endclass
  class db39 extends bb39;
    function new(int q = 0);
      super.new(q);
    endfunction
  endclass
endpackage

package r39b;
  import q39b::*;
  class hb39;
    // BASED literals against the property width.
    int       k_wide  = 8'hff;      // literal narrower than the property
    bit [3:0] k_narrow = 8'hff;     // literal wider than the property
    int       k_bin   = 4'b1010;
    int       k_dec   = 32'd7;
    logic [7:0] k_x   = 8'hx;
    // ::-qualified call WITH arguments (the uvm_register_cb shape).
    int       k_qargs = q39b::kb39#(2)::sf(1, "s");
    // PACKAGE-qualified call.
    int       k_pkgq  = q39b::qf39(4);
    // `new` on a derived class and through a typedef.
    db39      k_dnew  = new(2);
    // A property initialised from ANOTHER property (a bare name control).
    int       k_ref   = k_wide;
  endclass
endpackage

module t39b;
  r39b::hb39 h;
  initial h = new();
endmodule
