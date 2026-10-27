// § uninstIfaceIncDecBinds441
interface ifc;
int garr[2];
function void f1(int s); garr[s]++; s--; endfunction
endinterface
module top;
  ifc u();
endmodule
