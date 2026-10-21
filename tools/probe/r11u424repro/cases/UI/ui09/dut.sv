// § ifcUnitVarRefMintsNet424
package p;
  function automatic bit en(int v, string id); return id == "X"; endfunction
endpackage
import p::*;
string label = "X";
interface ifc(input bit clk, input read, input write);
  assert property (@(posedge clk) !(read & write)) else begin
    if (en(1, label)) $error("%s", label);
  end
endinterface
module top;
  bit c; logic r, w;
  ifc d(.clk(c), .read(r), .write(w));
endmodule
