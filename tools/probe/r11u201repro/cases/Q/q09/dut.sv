// § nonReduceOpArgBare201 § opCtxRefArgBare201
module top (input logic c, input logic [3:0] a, input logic [3:0] p1 [4], input logic [7:0] w, output logic [3:0] y1, output logic [3:0] y2, output logic [3:0] y3, output logic [7:0] y4);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  function automatic logic [3:0] g(input logic [3:0] x); return x ^ 4'h5; endfunction
  assign y1 = f(a) ^ 4'd1;
  assign y2 = ~^f(w[3:0]) ? 4'd1 : 4'd0;
  assign y3 = 4'(f(p1[0]) === 4'd1);
endmodule
