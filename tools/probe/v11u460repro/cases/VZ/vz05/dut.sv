// § clsArrPatBasedLitElemW460 (real element)
class C;
  real r[] = '{'h1, 'h2};
endclass
module top;
  real m[2] = '{'h3, 'h4};
  initial begin C c; c = new; end
endmodule
