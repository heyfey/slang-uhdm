// § caReduceOpKindGate276
module dut #(parameter logic [7:0] P = 8'h3C) (input logic [7:0] n, input logic [3:0] a, b, output logic [7:0] o);
  assign o = (P & n) ^ {a, b};
endmodule
