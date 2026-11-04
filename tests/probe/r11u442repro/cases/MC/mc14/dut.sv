// § modClassTdListing442
class C;
endclass
module top;
  typedef C c_t;
  c_t arr[2];
endmodule
module other;
  typedef C c_t;
  c_t x [5];
endmodule
