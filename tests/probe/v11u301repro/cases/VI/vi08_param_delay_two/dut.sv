// § caInsideRhsClonesCell301
module child #(parameter int D = 2) (input logic [3:0] a, output logic o);
  assign #D o = a inside {1, 2};
endmodule
module dut (input logic [3:0] a, output logic [1:0] o);
  child #(.D(5)) u0 (.a(a), .o(o[0]));
  child #(.D(6)) u1 (.a(a), .o(o[1]));
endmodule
