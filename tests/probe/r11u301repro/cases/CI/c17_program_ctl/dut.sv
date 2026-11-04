// § caInsideRhsClonesCell301
program prg (input logic [3:0] a, output logic o);
  assign o = a inside {[4'd2:4'd6]};
endprogram
module dut (input logic [3:0] a, output logic o);
  prg p (.a(a), .o(o));
endmodule
