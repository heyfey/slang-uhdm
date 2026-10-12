// § caInsideRhsClonesCell301
module dut (input logic [3:0] a, output logic o);
  logic v;
  assign v = a inside {4'd7, [4'd9:4'd11]};
  assign o = v;
endmodule
