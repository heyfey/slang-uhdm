// § refSignSrcSurelogSigned264v
module sub #(parameter bit E = 1) (output logic [31:0] o);
  localparam shortint S = 3;
  localparam U = 4;
  localparam int I = 5;
  localparam int K1 = E ? S : I;
  localparam int K2 = E ? U : I;
  localparam int K3 = E ? I : S;
  localparam int K4 = +S;
  assign o = '0;
endmodule
module top(output logic [31:0] o);
  sub u(.o(o));
endmodule
