// § fixedOuterAssocInnerReg223
module dut;
  typedef int at_t [4][int];
  at_t x;
  int mi [2][int] = '{'{1:2}, '{3:4}};
  int mr [1:0][int];
endmodule
