// § opCtxRefArgBare201
module top(input logic [3:0] a, input logic c, output logic [3:0] o1, output logic [3:0] o2, output logic [3:0] o3, output logic [7:0] o4, output logic o5);
  function automatic logic [3:0] f(input logic [3:0] v); return v + 1; endfunction
  assign o1 = (f(a));
  assign o2 = 4'(f(a));
  assign o3 = c ? f(a) + 4'd1 : 4'd0;
  assign o4 = {f(a), 4'h0};
  assign o5 = f(a) == 4'd3;
endmodule
