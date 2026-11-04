// § cgArrayElemUnsupportedTs436
interface ifc (input clk, input a);
covergroup cg();
  coverpoint a;
endgroup
cg cgs[3];
endinterface
