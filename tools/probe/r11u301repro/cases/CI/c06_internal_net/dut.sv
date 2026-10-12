// § caInsideRhsClonesCell301
module dut (input logic [3:0] a, output logic o);
  wire w;
  assign w = a inside {[4'd1:4'd3]};
  assign o = w;
endmodule
