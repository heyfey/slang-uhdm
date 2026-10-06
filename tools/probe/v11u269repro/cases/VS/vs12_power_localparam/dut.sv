// § selOpFoldReducibleKinds269v
module m #(parameter P = 2) (output wire [7:0] w);
  localparam L = 4'd2;
  assign w[3:0] = L ** 4'd2;
  assign w[7:4] = L - 4'd1;
endmodule
module top(output wire [7:0] w);
  m u(.w(w));
endmodule
