// § caInsideRhsClonesCell301
module child #(parameter int P = 2) (output logic o);
  localparam int L = 5;
  assign o = L inside {[P:P+3]};
endmodule
module dut (output logic [1:0] o);
  child #(.P(1)) u0 (.o(o[0]));
  child #(.P(9)) u1 (.o(o[1]));
endmodule
