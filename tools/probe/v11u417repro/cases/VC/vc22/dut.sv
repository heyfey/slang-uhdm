// § foreachArrayNamesClass417
class b;
  int v;
endclass
module top (input int b[3], output int n);
  always_comb begin
    n = 0;
    foreach (b[i]) n += b[i];
  end
endmodule
