// face-3 break: leak + the item is also used via export in pb
package pa;
  parameter logic [31:0] CV = {1'b0, 31'd22};
endpackage
package pb; import pa::*; parameter logic [7:0] QB = 8'h1; endpackage
package pc; import pb::*; parameter logic [7:0] QC = 8'h2; endpackage
package pd; import pa::*; export pa::CV; endpackage
module top import pb::*; import pd::*; (output logic [31:0] o); assign o = CV; endmodule
