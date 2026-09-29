// § fixedOuterAssocInnerReg223 § unsizedInnerSizeDeclines223 — $size of int ma [4][int] in a net initializer (the base segfaulted in the elaborated view)
module dut (output logic [7:0] o3);
  int ma [4][int];
  wire [7:0] w3 = $size(ma);
  assign o3 = w3;
endmodule
