// § modClassTdListing442
class C #(int W = 4);
  logic [W-1:0] d;
endclass
module top;
  typedef C#(8) c8_t;
  c8_t h;
endmodule
