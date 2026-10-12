// § defNetClassArrTsDimEnd293
// An interface class handle array.
interface class I;
  pure virtual function int get();
endclass
module top;
  I a [];
  int r_o;
  initial r_o = a.size();
endmodule
