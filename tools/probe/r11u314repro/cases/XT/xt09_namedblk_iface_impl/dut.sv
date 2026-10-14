// § tfLvTrailIdxNamedBlkScope314
class holder; int idx[4]; endclass
interface ifc; holder h; task automatic t(input int i); begin : b int j; j = i; h.idx[j + 1] = 0; end endtask endinterface
module top; ifc u(); endmodule
