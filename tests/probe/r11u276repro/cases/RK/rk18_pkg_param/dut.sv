// § caReduceOpKindGate276
package pk; parameter logic [7:0] K = 8'h42; endpackage
module dut import pk::*; #(parameter logic [7:0] P = 8'h3C) (input logic [7:0] n, n2, output logic [7:0] o);
  assign o = (P & K & n) ^ n2;
endmodule
