// § clsArrPatBasedLitElemW460
class C;
  int d[] = '{64'h9, 4'b1, 'd5, 16'd3, 'sh7};
  byte b[] = '{32'hff, 'o3};
  int q[$] = {4'hf, 'h2};
endclass
module top;
  initial begin C c; c = new; end
endmodule
