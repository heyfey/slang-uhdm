// § defNetClassArrTsDimEnd293
// A class handle array inside a generate block.
class C; int x; endclass
module top;
  if (1) begin : g
    C a [];
    int r_o;
    initial begin a = new[2]; r_o = a.size(); end
  end
endmodule
