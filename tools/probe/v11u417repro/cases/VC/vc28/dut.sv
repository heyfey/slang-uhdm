// § foreachArrayNamesClass417
class b;
  int v;
endclass
module top;
  int b[3];
  int n;
  initial begin
    foreach (b[i]) n += i;
    foreach (b[k]) n -= k;
  end
endmodule
