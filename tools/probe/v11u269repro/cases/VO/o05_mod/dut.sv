// § selOpFoldReducibleKinds269v
module m #(parameter P = 4'd3, parameter N = 3, parameter logic [3:0] PT = 4'd3) (output wire [7:0] w);
  assign w[3:0] = 4'd7 % 4'd2;
  assign w[7:4] = '0;
endmodule
module top(output wire [7:0] w);
  m u(.w(w));
endmodule
