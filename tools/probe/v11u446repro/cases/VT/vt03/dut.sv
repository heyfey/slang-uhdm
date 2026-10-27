// § clsLocalTdTopHomeInst446
package p;
  class pool #(type K = int, type T = int);
    typedef pool #(K, T) this_type;
    typedef T val_t;
    static function this_type get();
      return null;
    endfunction
  endclass
  typedef pool #(string, int) sp_t;
  typedef pool #(int, byte) ib_t;
endpackage
module top;
  import p::*;
  sp_t a;
  ib_t b;
  initial a = sp_t::get();
endmodule
