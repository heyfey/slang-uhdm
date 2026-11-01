// § clsArrPatBasedLitElemW460 (shortint overflow, int unsigned)
class C;
  shortint s[] = '{'h1ffff, 'h7};
  int unsigned u[] = '{'hffffffff, 'o1};
endclass
module top;
  initial begin C c; c = new; end
endmodule
