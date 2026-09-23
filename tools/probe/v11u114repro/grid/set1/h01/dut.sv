// face-3 break: three-hop leak (pa->pb->pc->module)
package pa;
  parameter logic [31:0] CV = {1'b0, 31'd22};
endpackage
package pb; import pa::*; parameter logic [7:0] QB = 8'h1; endpackage
package pc; import pb::*; parameter logic [7:0] QC = 8'h2; endpackage
module top import pc::*; (output logic [31:0] o); assign o = QC; endmodule
