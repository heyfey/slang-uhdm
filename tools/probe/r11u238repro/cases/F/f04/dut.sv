// § foreachFlatLocalRefTs238
module top;
  string vals[$];
  string arr[4];
  int n;
  initial begin
    foreach (vals[i]) n++;
    foreach (arr[k]) n++;
  end
endmodule
