// r10uvm203 grid arm E — the NEGATIVE CONTROL: a package with no out-of-body
// constructor and no container variable.  Nothing this law adds may appear.
package pe203;
  int    e_int = 1;
  string e_str = "e";
  class Ce203;
    int p;
    function new(); p = 0; endfunction   // an IN-BODY constructor
    function void m();
      int e_m_local;                     // an in-body method local
      e_m_local = 0;
    endfunction
  endclass
  Ce203 e_h;
endpackage

import pe203::*;

module ge203;
  bit clk;
endmodule
