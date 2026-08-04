package p;
  function int pf(int a);
    return a;
  endfunction
  class base;
    static int sv;
    static function int sf(int a);
      return a;
    endfunction
    function int callsibling(int a);
      return sf(a);
    endfunction
  endclass
  class holder;
    int r;
    function void go();
      r = pf(1);
      r = p::pf(2);
      r = base::sv;
      r = base::sf(3) + p::pf(4);
    endfunction
  endclass
endpackage

module top;
  import p::*;
  int z;
  initial begin
    z = p::pf(5);
    z = p::base::sv;
  end
endmodule
