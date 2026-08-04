package p;
  class base;
    static function int sf(int a);
      return a;
    endfunction
  endclass
  class gen #(type T = int);
    static function int gf(int a);
      return a;
    endfunction
  endclass
  class holder;
    typedef base alias_t;
    int r;
    function void go();
      r = base::sf(1);
      r = p::base::sf(2);
      r = gen#(int)::gf(3);
      r = gen#(bit)::gf(4);
      r = alias_t::sf(5);
      r = base::sf(base::sf(6));
    endfunction
  endclass
endpackage

module top;
  import p::*;
  int z;
  initial begin
    z = p::base::sf(7);
    z = gen#(int)::gf(8);
  end
endmodule
