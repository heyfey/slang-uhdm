// § modClassTdListing442
module top;
  class C;
    int x;
  endclass
  typedef C c_t;
  c_t h;
  initial h = new;
endmodule
