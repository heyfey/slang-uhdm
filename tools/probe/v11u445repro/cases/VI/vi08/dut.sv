// § ifaceLoopVarReadBindsDecl445
interface ifc;
int q[$]; int r[$];
initial begin int x; r = q.find(x) with (x > 0); end
endinterface
module top; ifc u(); endmodule
