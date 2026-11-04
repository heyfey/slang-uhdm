// § caInsideRhsClonesCell301
module leaf (input logic [3:0] a, output logic o);
  assign o = a inside {[4'd2:4'd6]};
endmodule
module mid (input logic [3:0] a, output logic o);
  leaf l (.a(a), .o(o));
endmodule
module dut (input logic [3:0] a, output logic o);
  mid m (.a(a), .o(o));
endmodule
