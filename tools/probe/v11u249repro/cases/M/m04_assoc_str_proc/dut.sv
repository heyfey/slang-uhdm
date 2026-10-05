// § modDynArrTd249
module top;
  typedef int a_t[string];
  a_t a; int n;
  initial begin a["x"] = 1; n = a.num(); end
endmodule
