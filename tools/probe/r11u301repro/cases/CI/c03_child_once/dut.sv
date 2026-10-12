// § caInsideRhsClonesCell301
module child (input logic [7:0] a, output logic o);
  assign o = a inside {[8'd3:8'd12], 8'd20};
endmodule
module dut (input logic [7:0] a, output logic o);
  child u (.a(a), .o(o));
endmodule
