// § ifcUnitVarRefMintsNet424 (control: a module assertion action calling a package function)
package p;
  function automatic bit en(int v, string id); return id == "X"; endfunction
endpackage
import p::*;
string label = "X";
module m(input bit clk, input read, input write);
  assert property (@(posedge clk) !(read & write)) else begin
    if (en(1, label)) $error("%s", label);
  end
endmodule
module top;
  bit c; logic r, w;
  m d(.clk(c), .read(r), .write(w));
endmodule
