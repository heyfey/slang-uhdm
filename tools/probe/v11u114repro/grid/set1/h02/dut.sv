// face-3 break: leak + explicit import of the item from its home
package pa;
  parameter logic [31:0] CV = {1'b0, 31'd22};
endpackage
package pb; import pa::*; parameter logic [7:0] QB = 8'h1; endpackage
package pc; import pb::*; parameter logic [7:0] QC = 8'h2; endpackage
module top import pb::*; (output logic [31:0] o); import pa::CV; assign o = CV; endmodule
