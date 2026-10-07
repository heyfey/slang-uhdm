// § caReduceOpKindGate276
module dut #(parameter logic [7:0] P = 8'h3C) (input logic [7:0] n, m, output logic [7:0] o);
  assign o = (P ^ n) & m;
endmodule
