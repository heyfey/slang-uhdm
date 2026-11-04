// § newArrayBitSelIdxOpStripped224
module top(output int o);
  int arr[4]; int k;
  task automatic t(output int r);
    int la[];
    la = new[arr[arr[k]+1]];
    r = la.size();
  endtask
  initial begin arr = '{1,2,3,0}; k = 0; t(o); end
endmodule
