// § modKwlessTypeParamDropped412
module top #(type T = logic [3:0], parameter W = 2) (input T a, output T b, output logic [W-1:0] c);
  assign b = a;
  assign c = a[W-1:0];
endmodule
