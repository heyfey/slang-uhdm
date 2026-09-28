// § sysCtxRefArgBare201
module s02 (input logic [3:0] a, input logic [7:0] w, output logic [31:0] y1, output logic [31:0] y2, output logic [31:0] y3, output logic y4, output logic y5);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  assign y1 = $bits(f(a));
  assign y2 = $size(f(w[3:0]));
  assign y3 = $high(f(a));
  assign y4 = $onehot0(f(w[1 +: 4]));
  assign y5 = $isunknown(f(a) & w[3:0]);
endmodule
