// § caInsideRhsClonesCell301
module dut (input logic [3:0] a, output logic o);
  assign o = a inside {[4'd3:$]};
endmodule
