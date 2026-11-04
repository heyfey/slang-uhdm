// § foreachArrayPlaceholderFile140
module dut;
  int aa[string];
  int tot;
  initial begin
    aa["a"] = 1;
    foreach (aa[k]) tot += aa[k];
  end
endmodule
