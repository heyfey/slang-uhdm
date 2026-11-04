// § opCtxRefArgBare201
module unused(input logic [3:0] a, output logic [3:0] o);
  function automatic logic [3:0] f(input logic [3:0] v); return v + 1; endfunction
  assign o = f(a) + 4'd1;
endmodule
module top(input logic [3:0] a, output logic [3:0] o);
  function automatic logic [3:0] f(input logic [3:0] v); return v + 2; endfunction
  assign o = f(a) + 4'd1;
endmodule
