// § caInsideRhsClonesCell301
module dut (input logic [3:0] a, b, output logic o, p);
  assign o = a inside {4'd1}, p = b inside {[4'd2:4'd3]};
endmodule
