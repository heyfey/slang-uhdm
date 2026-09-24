// VERIFIER arm v3 — the OUT-OF-BODY / OWN-CLASS cell with a package free twin.
// Neither a1 nor a2 pins it: a1's oob cells are all INHERITED names, and a2's
// own-class control (`own`) has NO package twin.  Here the gate fires on
// `curSubOob9` ALONE (callee == caller), which is the one way inheritedCall72
// becomes true without any inheritance at all.
package r1;

  function int ow(int v);           // the package free twin
    return v + 200;
  endfunction

  class ownc;
    int r;
    function int ow(int v);         // OWN method of the same name
      return v + 2;
    endfunction
    function void inb_own();
      r = ow(3);                    // IN-BODY, own class  -> must bind METHOD
    endfunction
    extern function void oob_own();
  endclass

  function void ownc::oob_own();
    r = ow(4);                      // OUT-OF-BODY, own class, free twin exists
  endfunction

endpackage

module top;
  r1::ownc o;
  initial begin
    o = new(); o.inb_own(); o.oob_own();
  end
endmodule
