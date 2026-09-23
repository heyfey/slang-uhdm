// face-3 break: leak of a concat param into TWO modules one of which also imports pa
package pa;
  parameter logic [31:0] CV = {1'b0, 31'd22};
endpackage
package pb; import pa::*; parameter logic [7:0] QB = 8'h1; endpackage
package pc; import pb::*; parameter logic [7:0] QC = 8'h2; endpackage
module s1 import pb::*; (output logic [7:0] o); assign o = QB; endmodule
module s2 import pa::*; import pb::*; (output logic [31:0] o); assign o = CV; endmodule
module top(output logic [7:0] a, output logic [31:0] b); s1 u1(.o(a)); s2 u2(.o(b)); endmodule
