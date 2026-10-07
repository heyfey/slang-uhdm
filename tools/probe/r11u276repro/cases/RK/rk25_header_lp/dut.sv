// § caReduceOpKindGate276
module dut #(localparam logic [7:0] P = 8'h3C) (input logic [7:0] n, n2, output logic [7:0] o);
  assign o = (P & n) ^ n2;
endmodule
