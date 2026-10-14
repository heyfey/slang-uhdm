// § tfLvTrailIdxNamedBlkScope314
class holder; int idx[4]; endclass
module top #(parameter int S = 1); holder h; case (S) 1: begin : gc task t(input int i); begin : b int j; j = i; h.idx[j + 1] = 0; end endtask end default: ; endcase endmodule
