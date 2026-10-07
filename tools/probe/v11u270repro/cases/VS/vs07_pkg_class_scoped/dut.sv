// § scopedCallPrefixEndsAtColons270
package p;
  class reg_t #(type T = int);
    static function T create(string n); return null; endfunction
  endclass
  class c;
    static int k;
    static function int get(); return k; endfunction
    typedef reg_t#(c) type_id;
  endclass
endpackage
module top;
  int r;
  p::c h;
  initial begin
    r = p::c:: get();
    r = p::c::
        k;
    h = p::c::type_id::
        create("x");
  end
endmodule
