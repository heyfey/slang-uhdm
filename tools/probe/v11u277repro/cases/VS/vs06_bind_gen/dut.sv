// § strPortNetTsFromPortDecl277
module chk(o);
  output [2:0] o;
  wire (weak1, weak0) [2:0] o = 3'd2;
endmodule
module m(input [2:0] i, output [2:0] z);
  assign z = i;
endmodule
module top(output [2:0] z, output [2:0] w0, output [2:0] w1);
  m u(.i(3'd1), .z(z));
  bind m chk c(.o());
  genvar g;
  for (g = 0; g < 2; g++) begin : gb
    wire [2:0] w;
    chk k(.o(w));
  end
  assign w0 = gb[0].w;
  assign w1 = gb[1].w;
endmodule
