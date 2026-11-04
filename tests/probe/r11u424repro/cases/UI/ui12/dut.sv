// § ifcUnitVarRefMintsNet424 (an interface process calling a package function)
package p;
  function automatic bit en(int v, string id); return id == "X"; endfunction
endpackage
import p::*;
string label = "X";
interface ifc(input bit clk, input read, input write);
  initial if (en(1, label)) $error("%s", label);
endinterface
module top;
  bit c; logic r, w;
  ifc d(.clk(c), .read(r), .write(w));
endmodule
