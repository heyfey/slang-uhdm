// § caInsideRhsClonesCell301
module dut (input logic [7:0] a, output logic o);
  assign o = a inside {[8'd3:8'd12]};
endmodule
