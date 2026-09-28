// § opCtxRefArgBare201
module sub (input logic [3:0] a, output logic [3:0] y);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  assign y = f(a) - 4'd1;
endmodule
module mid (input logic [3:0] a, output logic [3:0] y);
  sub s (.a(a), .y(y));
endmodule
module top (input logic [3:0] a, output logic [3:0] y1, output logic [3:0] y2);
  mid m1 (.a(a), .y(y1));
  sub s2 (.a(a), .y(y2));
endmodule
