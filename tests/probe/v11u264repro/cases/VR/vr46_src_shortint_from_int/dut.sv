// § refSignSrcSurelogSigned264v
module sub (output logic [31:0] o);
  localparam int I = 4;
  localparam shortint A = I;
  localparam int B = A;
  assign o = '0;
endmodule
module top(output logic [31:0] o);
  sub u(.o(o));
endmodule
