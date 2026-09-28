// § sysCtxRefArgBare201
module sub (input logic [3:0] a, output logic [3:0] y);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  assign y = 4'($countones(f(a)) ^ $signed(f(a)));
endmodule
module top (input logic [3:0] a, output logic [3:0] y, output logic [3:0] y2);
  sub u1 (.a(a), .y(y));
  sub u2 (.a(~a), .y(y2));
endmodule
