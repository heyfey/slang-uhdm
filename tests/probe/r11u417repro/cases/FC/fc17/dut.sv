// § foreachArrayNamesClass417
class b;
  int v;
endclass
module top;
  int b[string];
  int n;
  initial begin
    b["x"] = 1;
    foreach (b[s]) n += b[s];
  end
endmodule
