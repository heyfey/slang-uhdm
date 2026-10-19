// § assocWildcardIdxRefTs412
module sub;
  logic [3:0] w [*];
  byte b [*][2];
endmodule
module top ();
  sub u();
  int arr [*];
  int brr [string];
  initial arr[3] = 1;
endmodule
