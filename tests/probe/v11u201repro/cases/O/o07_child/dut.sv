// § opCtxRefArgBare201
module sub #(parameter int K = 1) (input logic [3:0] a, output logic [3:0] o);
  function automatic logic [3:0] f(input logic [3:0] v); return v + K; endfunction
  assign o = f(a) + 4'd1;
endmodule
module top(input logic [3:0] a, output logic [3:0] o1, output logic [3:0] o2);
  sub #(.K(2)) u1(.a(a), .o(o1));
  sub u2(.a(a), .o(o2));
endmodule
