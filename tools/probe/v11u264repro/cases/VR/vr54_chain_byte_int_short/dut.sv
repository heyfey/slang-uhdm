// § refSignSrcSurelogSigned264v
module sub (output logic [31:0] o);
  localparam int I = 4;
  localparam byte Y = I;
  localparam shortint S = Y;
  localparam int B = S;
  assign o = '0;
endmodule
module top(output logic [31:0] o);
  sub u(.o(o));
endmodule
