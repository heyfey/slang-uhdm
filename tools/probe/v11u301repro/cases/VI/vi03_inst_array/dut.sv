// § caInsideRhsClonesCell301
module child (input logic [3:0] a, output logic o);
  assign o = a inside {[2:5]};
endmodule
module dut (input logic [3:0] a, output logic [1:0] o);
  child u [1:0] (.a(a), .o(o));
endmodule
