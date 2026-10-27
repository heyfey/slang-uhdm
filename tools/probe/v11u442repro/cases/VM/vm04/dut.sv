// § modClassTdListing442
class C;
endclass
module top(input logic clk);
  typedef C c_t;
  c_t a = null, b [2];
endmodule
