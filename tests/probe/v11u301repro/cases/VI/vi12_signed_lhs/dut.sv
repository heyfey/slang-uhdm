// § caInsideRhsClonesCell301
module dut (input logic signed [3:0] a, output logic signed [3:0] o);
  assign o = a inside {-4'sd1, 4'sd2};
endmodule
