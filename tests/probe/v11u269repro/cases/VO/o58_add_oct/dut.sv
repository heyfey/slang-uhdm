// § selOpFoldReducibleKinds269v
module m #(parameter P = 4'd3, parameter N = 3, parameter logic [3:0] PT = 4'd3) (output wire [7:0] w);
  assign w[5:0] = 6'o12 + 6'o01;
  assign w[7:6] = '0;
endmodule
module top(output wire [7:0] w);
  m u(.w(w));
endmodule
