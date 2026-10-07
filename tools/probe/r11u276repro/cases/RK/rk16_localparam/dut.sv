// § caReduceOpKindGate276
module dut (input logic [7:0] n, n2, output logic [7:0] o);
  localparam logic [7:0] L = 8'h5A;
  assign o = (L | n) ^ n2;
endmodule
