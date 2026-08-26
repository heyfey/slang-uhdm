// r10v160 cell d10 — a rejected concatenation as a REPLICATION body.
package pd10_160;
  class based10160;
    function new(string name="x"); endfunction
  endclass
  class hold10160 #(type T=int) extends based10160;
    static string sd = "";
    function void m(); T t; sd = {2{ {"[", t.gt(), "]"} }}; endfunction
  endclass
endpackage
module topd10160;
  initial $display("hi");
endmodule
