// § caReduceOpKindGate276
module dut #(parameter int P = 2) (input logic [3:0] n, input logic [7:0] m, output logic [7:0] o);
  assign o = {P{n}} ^ m;
endmodule
