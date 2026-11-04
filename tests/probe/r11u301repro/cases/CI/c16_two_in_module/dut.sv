// § caInsideRhsClonesCell301
module child (input logic [3:0] a, output logic o, output logic p);
  assign o = a inside {[4'd2:4'd6]};
  assign p = a inside {4'd1, 4'd8};
endmodule
module dut (input logic [3:0] a, output logic [3:0] o);
  child u0 (.a(a), .o(o[0]), .p(o[1]));
  child u1 (.a(~a), .o(o[2]), .p(o[3]));
endmodule
