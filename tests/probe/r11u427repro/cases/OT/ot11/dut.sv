// § ovUntypedTsDeclWidth427
module sub #(parameter A = 1'b0, parameter B = 4'b0)(input a, output o);
  assign o = a ^ A[0] ^ B[0];
endmodule
module mid #(parameter W = 2'b10)(input a, output [1:0] o);
  sub #(.A(W), .B(8'hA5)) s1(.a(a), .o(o[0]));
  sub #(.A(3'b111)) s2(.a(a), .o(o[1]));
endmodule
module top(input a, output [3:0] o);
  mid #(.W(5'b10101)) m1(.a(a), .o(o[1:0]));
  for (genvar g = 0; g < 1; g++) begin : gb
    sub #(.A(2'b10)) s3(.a(a), .o(o[2]));
  end
  sub #(.B(6'd33)) s4(.a(a), .o(o[3]));
endmodule
