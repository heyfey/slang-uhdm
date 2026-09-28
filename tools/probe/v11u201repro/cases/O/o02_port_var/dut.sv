// § opCtxRefArgBare201
module top(input logic [3:0] a, input logic [7:0] w, output logic [3:0] o1, output wire [3:0] o2);
  function automatic logic [3:0] f(input logic [3:0] v); return v + 1; endfunction
  logic [3:0] lv;
  assign o1 = f(a) + 4'd1;
  assign o2 = f(w[3:0]) - 4'd2;
  assign lv = f(w[7:4]) & 4'h7;
endmodule
