// § caReduceOpKindGate276
module dut #(parameter logic [7:0] P = 8'h3C) (input logic [7:0] n, output logic o);
  assign o = ((P | n) ==? 8'b1x0z1100);
endmodule
