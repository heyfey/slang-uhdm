// § caInsideRhsClonesCell301
module dut (input logic [3:0] a, output logic o);
  assign #2 o = a inside {[4'd1:4'd2]};
endmodule
