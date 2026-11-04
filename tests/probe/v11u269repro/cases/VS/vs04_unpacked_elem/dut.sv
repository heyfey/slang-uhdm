// § selLhsOpFoldFresh269
module m(output logic [3:0] o);
  wire [3:0] arr [2];
  assign arr[1] = {2{2'b10}};
  assign arr[0] = 4'h1 + 4'h2;
  assign o = arr[1] ^ arr[0];
endmodule
module top(output logic [3:0] o);
  m u(.o(o));
endmodule
