// § opCtxRefArgBare201
module top(input logic [3:0] a, output logic [3:0] o1, output logic [3:0] o2);
  function automatic logic [3:0] f(input logic [3:0] v); return v + 1; endfunction
  localparam int D = 2;
  assign #D o1 = f(a) + 4'd1;
  assign #1 o2 = f(a) + 4'd1;
endmodule
