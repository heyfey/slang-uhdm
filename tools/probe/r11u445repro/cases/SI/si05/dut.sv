// § ifaceLoopVarReadBindsDecl445
interface ifc;
logic [3:0] sig;
int s;
function automatic void f(int i); foreach (sig[i]) s = s + i; endfunction
endinterface
module top; ifc u(); endmodule
