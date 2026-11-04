// § caReduceOpKindGate276
module dut #(parameter logic [7:0] P = 8'h3C, parameter logic [7:0] Q = 8'h11) (input logic [7:0] n, output logic o);
  assign o = n[0] ^ P[1] ^ Q[2];
endmodule
