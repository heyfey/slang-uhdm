// § defNetClassArrTsDimEnd293
// A CRLF file with a class array.
class C; int x; endclass
module top;
  C a [];
  int r_o;
  initial r_o = a.size();
endmodule
