// § modClassTdListing442
class C;
endclass
module child;
  typedef C c_t;
  c_t h;
endmodule
module top;
  child u1();
  child u2();
endmodule
