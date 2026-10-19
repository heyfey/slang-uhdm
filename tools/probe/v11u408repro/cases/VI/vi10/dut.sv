// § ifaceClassNotListed408
interface class I #(int W = 4);
  pure virtual function logic [W-1:0] f();
endclass
class C implements I#(8);
  virtual function logic [7:0] f(); return 8'h1; endfunction
endclass
module test;
  C h;
  logic [7:0] r;
  initial begin h = new; r = h.f(); end
endmodule
