// § caReduceOpKindGate276
package pk; parameter logic [7:0] P = 8'h3C; endpackage
module dut (input logic [7:0] n, m, output logic [7:0] o);
  assign o = (pk::P & n) ^ m;
endmodule
