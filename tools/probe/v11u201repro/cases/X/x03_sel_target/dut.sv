// § nonReduceOpArgBare201
module top(input logic [3:0] a, output logic [7:0] o);
  function automatic logic [3:0] f(input logic [3:0] v); return v + 1; endfunction
  assign o[3:0] = f(a) ^ 4'd2;
  assign o[7:4] = f(a) ~^ 4'd2;
endmodule
