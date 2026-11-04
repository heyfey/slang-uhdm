// § ifaceClassNotListed408
interface class ic #(type T = int);
  pure virtual function T get();
  typedef int mytype;
  parameter int P = 3;
endclass
class c implements ic#(logic);
  virtual function logic get(); return 1'b0; endfunction
endclass
module test;
  c h;
  initial h = new;
endmodule
