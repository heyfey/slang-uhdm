// § arrElemVarKind406
module child(input byte bi [2], output shortint so [2]);
  assign so[0] = bi[0];
  assign so[1] = bi[1];
endmodule
module top;
  byte b [2];
  shortint s [2];
  child c(.bi(b), .so(s));
endmodule
