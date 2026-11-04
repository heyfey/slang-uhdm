// § caReduceOpKindGate276
module dut #(parameter logic [7:0] P = 8'h3C, parameter logic [7:0] Q = 8'hA5) (input logic [7:0] n, m, output logic [7:0] o);
  assign o = {4'b0, n[(P[1:0] ^ Q[1:0]) +: 4]};
endmodule
