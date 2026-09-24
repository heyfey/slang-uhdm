module inner #(parameter int W = 3, parameter type data_t = logic [W-1:0]) (input data_t a, output data_t [1:0] q);
  assign q = {a, ~a};
endmodule
module top (input logic [2:0] a, output logic [5:0] q);
  inner u (.a(a), .q(q));
endmodule
