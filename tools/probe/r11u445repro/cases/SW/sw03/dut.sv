// § ifaceLoopVarReadBindsDecl445
interface ifc;
int x; int q[$]; int r[$];
initial r = q.find(x) with (x > 0);
endinterface
module top; ifc u(); endmodule
