package p;
  class Inner;
    int x;
  endclass
  typedef Inner alias_t;

  class G #(type T = Inner);
    typedef G#(T) this_type;
    function T gf();
      T l;
      return l;
    endfunction
    function this_type hf();
      this_type h;
      return h;
    endfunction
    function alias_t af();
      alias_t a;
      return a;
    endfunction
  endclass

  class U;
    G #(Inner) g;
  endclass
endpackage

module top;
  import p::*;
  U u;
  initial begin
    u = new();
  end
endmodule
