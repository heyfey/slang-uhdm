// § newArrayBitSelIdxStripped220
module top(output int o);
  int d[];
  int arr[4];
  int k = 1;
  initial begin
    d = new[arr[k]];
    o = d.size();
  end
endmodule
