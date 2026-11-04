// § defNetClassArrTsDimEnd293
// A string-indexed associative class array.
class C; int x; endclass
module top;
  C a [string];
  int r_o;
  initial begin a["k"] = new(); r_o = a.num(); end
endmodule
