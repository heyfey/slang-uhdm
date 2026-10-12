// § caInsideRhsClonesCell301
module child #(parameter int P = 2) (input logic [7:0] a, b, output logic o);
  localparam int Q = P * 2;
  assign o = a inside {Q, b};
endmodule
module dut (input logic [7:0] a, b, output logic [1:0] o);
  child #(.P(3)) u0 (.a(a), .b(b), .o(o[0]));
  child #(.P(4)) u1 (.a(a), .b(b), .o(o[1]));
endmodule
