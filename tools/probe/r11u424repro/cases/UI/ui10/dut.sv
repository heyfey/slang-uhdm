// § ifcUnitVarRefMintsNet424 (control: the module road)
package p;
  function automatic bit en(int v, string id); return id == "X"; endfunction
endpackage
import p::*;
string label = "X";
module m(input bit clk, input read, input write);
  initial if (en(1, label)) $error("%s", label);
endmodule
module top;
  bit c; logic r, w;
  m d(.clk(c), .read(r), .write(w));
endmodule
