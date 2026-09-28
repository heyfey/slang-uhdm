// § opCtxRefArgBare201
module top(input logic [3:0] a, input logic [3:0] b, output logic [3:0] o1, output logic [3:0] o2);
  function automatic logic [3:0] f(input logic [3:0] v); return v + 1; endfunction
  function automatic logic [3:0] g(input logic [3:0] v, input logic [3:0] u); return v - u; endfunction
  assign o1 = f(a) + 4'd1, o2 = g(a, b) * 4'd2;
endmodule
