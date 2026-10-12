// § caInsideRhsClonesCell301
module dut (input logic [3:0] a, output logic o);
  assign o = a inside {4'b1?0?, 4'b0011};
endmodule
