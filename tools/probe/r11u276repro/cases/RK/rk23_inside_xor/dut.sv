// § caReduceOpKindGate276
module dut #(parameter logic [7:0] P = 8'h3C) (input logic [7:0] n, input logic m, output logic o);
  assign o = (n inside {P, 8'h1}) ^ m;
endmodule
