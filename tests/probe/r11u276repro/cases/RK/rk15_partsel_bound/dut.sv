// § caReduceOpKindGate276
module dut #(parameter int P = 4) (input logic [7:0] n, input logic [3:0] m, output logic [3:0] o);
  assign o = (n[P-1:0] & m) ^ m;
endmodule
