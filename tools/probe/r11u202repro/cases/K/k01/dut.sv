// § modGenericClassListedAtDefault200
module sub;
  class box #(type E = int); E v; endclass
  class plain; int a; endclass
  box #(byte) b;
  plain p;
endmodule
module top; sub u(); endmodule
