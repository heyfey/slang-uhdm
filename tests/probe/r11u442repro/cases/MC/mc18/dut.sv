// § modClassTdListing442
class C;
endclass
module top;
  typedef C c_t;
  c_t arr[2];
  initial begin
    c_t l [3];
  end
endmodule
