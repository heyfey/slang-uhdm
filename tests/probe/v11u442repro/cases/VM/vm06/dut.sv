// § modClassTdListing442
class C #(int W = 4);
  logic [W-1:0] d;
endclass
module child #(parameter int W = 2);
  typedef C#(W) c_t;
  c_t h;
endmodule
module top;
  child #(3) u1();
  child #(5) u2();
endmodule
