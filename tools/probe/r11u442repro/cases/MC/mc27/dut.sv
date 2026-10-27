// § modClassTdListing442
class C;
endclass
interface aif;
  typedef C i_t;
  i_t h;
endinterface
module top;
  typedef C c_t;
  c_t h;
  aif u();
endmodule
