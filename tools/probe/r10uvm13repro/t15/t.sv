package p1;
  typedef enum int { PE0 = 0, PE1 = 1, PE2 = 2 } pe_t;
endpackage

package p2;
  int gv;
  class ck;
    int r;
    function void inl();
      r = p1::PE1;          // A class-in-package method, qualified pkg enum
      if (r == p1::PE2) r = 5;
      $display("%0d", p1::PE0);
    endfunction
    extern function void oob();
  endclass
  function void ck::oob();
    r = p1::PE1;            // B out-of-body, qualified pkg enum
  endfunction
  function void pf();
    gv = p1::PE1;           // C package function, qualified (already folds)
  endfunction
endpackage

module top;
  int z;
  class mk;
    int r;
    function void inl();
      r = p1::PE1;          // D class-in-module method, qualified pkg enum
    endfunction
  endclass
  function void mf();
    z = p1::PE1;            // E module function, qualified
  endfunction
  initial begin
    z = p1::PE1;            // F module initial, qualified
    mf();
  end
endmodule
