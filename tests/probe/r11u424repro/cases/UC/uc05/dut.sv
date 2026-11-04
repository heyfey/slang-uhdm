// § ifcProcCallArgNoTs424
package p;
  function automatic bit en(int v, string id); return id == "X"; endfunction
endpackage
interface ifc(input bit clk, input read);
  string s = "X";
  assert property (@(posedge clk) read) else if (p::en(2, s)) $error("e");
endinterface
module top;
  bit c; logic r;
  ifc d(.clk(c), .read(r));
endmodule
