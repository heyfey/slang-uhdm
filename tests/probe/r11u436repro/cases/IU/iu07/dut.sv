// § ifaceDefArrNetDimSym436
interface ifc #(int N = 4) (input clk, input a);
covergroup cg();
  coverpoint a;
endgroup
cg cgs[N];
endinterface
