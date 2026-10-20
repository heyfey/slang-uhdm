// § foreachArrayNamesClass417
class b;
  int v;
endclass
module top;
  int b[3];
  int n;
  always_comb begin
    n = 0;
    foreach (b[i]) n = n + i;
  end
endmodule
