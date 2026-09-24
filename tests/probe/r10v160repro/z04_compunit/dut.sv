// r10v160 cell z04 — the rejected concatenation in a class at COMPILATION-UNIT
// scope (no package, no module).
class basev160;
  function new(string name="x"); endfunction
endclass
class hold160 #(type T=int) extends basev160;
  string s;
  function void m(); T t; s = {"[", t.gt(), "]"}; endfunction
endclass
module topv160;
  initial $display("hi");
endmodule
