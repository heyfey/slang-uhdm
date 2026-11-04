// § clsMethodOwnAutomatic462
interface class IC;
  pure virtual function int f();
endclass
class C implements IC;
  virtual function automatic int f(); return 1; endfunction
endclass
module top;
  initial begin C c; c = new; end
endmodule
