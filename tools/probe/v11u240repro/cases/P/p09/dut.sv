// § hoistPoolSourceOrder240: two modules, one importing at the module header, one in its body, depth 2 instance
package hp;
  class zb;
    int cnt, tot;
    extern function new();
    extern function int get();
  endclass
  function zb::new();
    tot = 0;
  endfunction
  function int zb::get();
    return cnt + tot;
  endfunction
endpackage
module leaf import hp::*; ();
  initial $display("l");
endmodule
module mid;
  import hp::*;
  leaf u_l();
endmodule
module top;
  mid u_m();
endmodule
