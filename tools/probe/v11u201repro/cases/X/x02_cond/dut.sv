// § nonReduceOpArgBare201
module top(input logic [3:0] a, input logic c, output logic [3:0] o1, output logic [3:0] o2, output logic [3:0] o3);
  function automatic logic [3:0] f(input logic [3:0] v); return v + 1; endfunction
  assign o1 = (f(a) === 4'd2) ? 4'd1 : 4'd0;
  assign o2 = c ? (f(a) ^ 4'd1) : 4'd0;
  assign o3 = $signed(f(a)) ^ 4'd3;
endmodule
