// § classRetFillUnsized433
interface class IC; pure virtual function logic [3:0] f(); endclass
class C implements IC;
  virtual function logic [3:0] f(); return '1; endfunction
endclass
module top; C c; initial c = new; endmodule
