// § arrElemVarKind406
module top;
  string test [4] = '{"111", "222", "333", "444"};
  initial foreach (test[i]) $display(i, test[i]);
endmodule
