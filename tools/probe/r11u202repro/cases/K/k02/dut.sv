// § modGenericClassListedAtDefault200
module sub;
  class zeta; int a; endclass
  class box #(type E = int); E v; endclass
  class alpha; int a; endclass
  box #(byte) b;
  zeta z; alpha q;
endmodule
module top; sub u(); endmodule
