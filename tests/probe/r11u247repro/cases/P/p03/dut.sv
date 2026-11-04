// § pureVirtFormalSignKwTrim247
interface class ic;
  pure virtual function void put(int unsigned v, logic signed [3:0] w);
endclass
class c implements ic;
  virtual function void put(int unsigned v, logic signed [3:0] w); endfunction
endclass
module top;
  c x;
  initial x = new();
endmodule
