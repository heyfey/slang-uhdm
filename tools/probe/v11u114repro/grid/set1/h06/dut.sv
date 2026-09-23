// face-3 break: leak of a replication
package pa;
  parameter logic [7:0] RP = {4{2'b10}};
endpackage
package pb; import pa::*; parameter logic [7:0] QB = 8'h1; endpackage
package pc; import pb::*; parameter logic [7:0] QC = 8'h2; endpackage
module top import pb::*; (output logic [7:0] o); assign o = QB; endmodule
