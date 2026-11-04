// § modClassTdListing442
class C;
  int x;
endclass
module top;
  typedef C c_t;
  c_t a;
  c_t b [3];
  initial a = new;
endmodule
