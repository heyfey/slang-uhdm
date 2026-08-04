package p1;
  typedef enum int { PE0 = 0, PE1 = 1 } pe_t;
  int pv;
  function int pkgf();
    pv = PE1;          // pkg body stmt, bare
    pv = p1::PE1;      // pkg body stmt, qualified
    return PE0;
  endfunction
  class k;
    typedef enum int { KE0 = 0, KE1 = 1 } ke_t;
    int r;
    function void inl();
      r = PE1;         // class method, package enum, bare
      r = p1::PE1;     // class method, package enum, qualified
      r = KE1;         // class method, own class enum, bare
    endfunction
    extern function void oob();
  endclass
  function void k::oob();
    r = PE1;           // out-of-body, package enum
    r = KE1;           // out-of-body, class enum
  endfunction
endpackage

package p2;
  import p1::*;
  int qv;
  function int q();
    qv = PE1;          // import-clone body stmt
    return PE0;
  endfunction
endpackage

module top;
  import p1::*;
  int z;
  p1::k h;
  initial begin
    z = PE1;
    z = p1::PE1;
  end
endmodule
