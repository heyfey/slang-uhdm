// § nonReduceOpArgBare201 § opCtxRefArgBare201
module o03 (input logic [3:0] a, input logic [1:0] b, output logic [3:0] y1, output logic y2, output logic y3, output logic [3:0] y4);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  assign y1 = f(a) ^ {b, b};
  assign y2 = f(a) === {2{b}};
  assign y3 = f(a) ==? 4'b1x0x;
  assign y4 = (f(a) ~^ a) + f(a[3:0]);
endmodule
