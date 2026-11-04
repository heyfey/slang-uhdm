// § sysCtxRefArgBare201
module top(input logic [7:0] a, input logic c, output logic [31:0] y1, output logic [31:0] y2, output logic y3);
  function automatic logic [3:0] f(input logic [3:0] v); return v ^ 4'h3; endfunction
  function automatic logic [3:0] g(input logic [3:0] v); return f(v) + 1; endfunction
  assign y1 = $countones(g(a[3:0])) + 1;
  assign y2 = $countones({f(a[7:4]), 4'h0});
  assign y3 = $onehot(c ? f(a[3:0]) : 4'h1);
endmodule
