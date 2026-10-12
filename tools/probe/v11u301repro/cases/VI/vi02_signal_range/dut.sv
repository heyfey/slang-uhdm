// § caInsideRhsClonesCell301
module dut (input logic [3:0] a, lo, hi, output logic o);
  assign o = a inside {[lo:hi]};
endmodule
