// r10v160 cell z01 — an LVALUE concatenation ONE OF WHOSE TARGETS binds bad.
// The law refuses lvalues (`inLhs`); this must stay byte-for-byte pristine.
package pv160;
  class basev160;
    function new(string name="x"); endfunction
  endclass
  class hold160 #(type T=int) extends basev160;
    bit [7:0] v1;
    function void m(); T t; {v1, t.fld} = 16'h55aa; endfunction
  endclass
endpackage
module topv160;
  initial $display("hi");
endmodule
