// § newArrayBitSelIdxOpStripped224
module top;
  int arr[4];
  int k;
  initial begin
    int local_addr[];
    local_addr = new[arr[k-1]];
  end
endmodule
