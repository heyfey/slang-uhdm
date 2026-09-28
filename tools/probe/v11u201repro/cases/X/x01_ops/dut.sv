// § nonReduceOpArgBare201
module top(input logic [3:0] a, input logic [7:0] w, output logic o1, output logic o2, output logic [3:0] o3, output logic o4);
  function automatic logic [3:0] f(input logic [3:0] v); return v + 1; endfunction
  assign o1 = f(a) === 4'd2;
  assign o2 = f(w[3:0]) !=? 4'b1x0x;
  assign o3 = (f(a) + 4'd1) ^ 4'd5;
  assign o4 = (f(a) ~^ f(w[7:4])) == 4'hf;
endmodule
