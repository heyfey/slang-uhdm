// § caReduceOpKindGate276
module dut #(parameter logic [7:0] P = 8'h3C, parameter logic [7:0] Q = 8'h0F) (input logic [7:0] n, output logic [7:0] o);
  assign o = P & ((Q & n) ^ n);
endmodule
