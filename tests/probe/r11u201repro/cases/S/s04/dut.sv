// § sysCtxRefArgBare201
module top (input logic c, input logic [3:0] a, input logic [3:0] p1 [4], input logic [7:0] w, output logic [3:0] y1, output logic [3:0] y2, output logic [3:0] y3, output logic [31:0] y4);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  logic [3:0] n1 = 4'($countones(f(a)));
  wire [3:0] n2 = 4'($countones(f(p1[0])));
  assign y1 = n1 + n2;
  assign y2 = 4'($countones(f(a)) + f(a));
endmodule
