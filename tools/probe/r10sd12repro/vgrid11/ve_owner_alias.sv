// vsd11 ve — the OWNER written through a TYPEDEF ALIAS of the class, and a
// TWO-LEVEL nested reach.  Both are reach questions the fix answers by
// construction (the written segment must BE the declaring class's name), and
// both are measured rather than argued.
package pve;

  class zele;
    int q;
  endclass
  class zme;
    int q;
  endclass

  class ahome;                  // sole namer of zele -> its typedef CLAIMS
    typedef zele home_t;
    class amid;
      class ainner;
        typedef zme deep_t;     // sole namer of zme -> CLAIMS
      endclass
    endclass
  endclass

  typedef ahome alias_c;        // an ALIAS of the owner CLASS itself

  class zuse;
    function void fe();
      ahome::home_t   v_direct;  // written owner IS the declaring class
      alias_c::home_t v_alias;   // written owner is an ALIAS of it
      ahome::amid::ainner::deep_t v_deep2; // THREE segments
      v_direct = null;
      v_alias = null;
      v_deep2 = null;
    endfunction
  endclass

endpackage

module topve;
  initial begin
    pve::zuse u = new();
    u.fe();
  end
endmodule
