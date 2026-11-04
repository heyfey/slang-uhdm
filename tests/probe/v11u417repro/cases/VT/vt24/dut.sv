// § foreachArrayNamesTypedef417
typedef int b;
module top;
  int b[$];
  int n;
  initial begin
    b.push_back(1);
    foreach (b[i]) n += b[i];
  end
endmodule
