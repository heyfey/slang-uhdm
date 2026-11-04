// § clsArrPatBasedLitElemW460 (control: concatenation and fixed array)
class C;
  int d[] = {'ha0, 'ha1};
  int f[2] = '{'ha0, 'ha1};
  int s = 'ha0;
endclass
module top;
  initial begin C c; c = new; end
endmodule
