// r10v160 cell z03 — the rejected concatenation inside a class declared in an
// INTERFACE, and one inside a class declared in a PROGRAM.
interface ifv160;
  class hi160 #(type T=int);
    string s;
    function void m(); T t; s = {"[", t.gt(), "]"}; endfunction
  endclass
endinterface
program prv160;
  class hp160 #(type T=int);
    string s;
    function void m(); T t; s = {"[", t.gt(), "]"}; endfunction
  endclass
  initial $display("hi");
endprogram
module topv160;
  ifv160 i0();
  initial $display("hi");
endmodule
