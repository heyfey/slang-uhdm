// face-3 break: leak of concat param in a module parameterized & instantiated twice
package pa;
  parameter logic [31:0] CV = {1'b0, 31'd22}; parameter logic [15:0] AR [2] = '{16'h1, {8'h2, 8'h3}};
endpackage
package pb; import pa::*; parameter logic [7:0] QB = 8'h1; endpackage
package pc; import pb::*; parameter logic [7:0] QC = 8'h2; endpackage
module sub import pb::*; #(parameter int W=1) (output logic [7:0] o); assign o = QB + W; endmodule
module top(output logic [7:0] a, b); sub #(1) u1(a); sub #(2) u2(b); endmodule
