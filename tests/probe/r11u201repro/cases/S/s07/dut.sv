// § sysCtxRefArgBare201
module top (input logic c, input logic [3:0] a, input logic [3:0] p1 [4], input logic [7:0] w, output logic [3:0] y1, output logic [3:0] y2, output logic [3:0] y3, output logic [31:0] y4);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  always_comb y1 = $countones(f(a));
  assign y2 = 4'($countones($signed(f(a))));
  assign y3 = 4'($signed($countones(f(a))));
endmodule
