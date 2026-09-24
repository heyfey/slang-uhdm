// § foreachArrayPlaceholderFile140
module top;
  int arr[4];
  int s;
  initial begin
    foreach (arr[i]) s += arr[i];
  end
endmodule
