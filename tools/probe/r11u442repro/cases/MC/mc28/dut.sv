// § modClassTdListing442
class C;
endclass
interface zif;
  typedef C i_t;
  i_t h;
endinterface
module top;
  typedef C c_t;
  c_t h;
  zif u();
endmodule
