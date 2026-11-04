// § caReduceOpKindGate276
module dut #(parameter logic [3:0] P = 4'h5) (input logic [3:0] n, input logic [7:0] m, output logic [7:0] o);
  assign o = {n, P} ^ m;
endmodule
