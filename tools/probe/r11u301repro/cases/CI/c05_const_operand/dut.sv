// § caInsideRhsClonesCell301
module child #(parameter int P = 2) (output logic o);
  assign o = P inside {1, 2, 3};
endmodule
module dut (output logic [1:0] o);
  child #(.P(7)) u0 (.o(o[0]));
  child u1 (.o(o[1]));
endmodule
