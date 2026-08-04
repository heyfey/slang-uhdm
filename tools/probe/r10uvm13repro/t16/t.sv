package p1;
  typedef enum int { PE0 = 0, PE1 = 1, PE2 = 2 } pe_t;
  int gv;
  // A: package function formal with an enum DEFAULT
  function void pf(int a, pe_t m = PE1);
    gv = a;
  endfunction
  class k;
    typedef enum int { KE0 = 0, KE1 = 1 } ke_t;
    int r;
    // B: in-class method formal, package enum default
    function void inl(int a, pe_t m = PE2);
      r = a;
    endfunction
    // C: in-class method formal, own class enum default
    function void inl2(int a, ke_t m = KE1);
      r = a;
    endfunction
    extern function void oob(int a, pe_t m = PE1);
  endclass
  // D: out-of-body method formal, package enum default
  function void k::oob(int a, pe_t m = PE1);
    r = a;
  endfunction
endpackage

module top;
  import p1::*;
  p1::k h;
  initial h = new();
endmodule
