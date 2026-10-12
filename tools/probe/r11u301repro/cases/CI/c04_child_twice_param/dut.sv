// § caInsideRhsClonesCell301
module child #(parameter int P = 2) (input logic [7:0] a, output logic o);
  assign o = a inside {[P:P+2]};
endmodule
module dut (input logic [7:0] a, output logic [1:0] o);
  child #(.P(4)) u0 (.a(a), .o(o[0]));
  child u1 (.a(a), .o(o[1]));
endmodule
