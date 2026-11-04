// § assocClassIdxNet412
module top;
  class C; endclass
  int arr [C];
  initial begin
    C k = new;
    arr[k] = 1;
  end
endmodule
