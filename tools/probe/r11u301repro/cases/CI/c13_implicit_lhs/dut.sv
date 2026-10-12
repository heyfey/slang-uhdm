// § caInsideRhsClonesCell301
module dut (input logic [3:0] a, output logic o);
  assign imp = a inside {[4'd2:4'd6]};
  assign o = imp;
endmodule
