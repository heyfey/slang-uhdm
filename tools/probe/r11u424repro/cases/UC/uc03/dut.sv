// § ifcProcCallArgNoTs424
function automatic int uf(int v); return v + 1; endfunction
interface ifc(input bit clk);
  int x;
  initial x = uf(2);
endinterface
module top;
  bit c;
  ifc d1(.clk(c));
  ifc d2(.clk(c));
endmodule
