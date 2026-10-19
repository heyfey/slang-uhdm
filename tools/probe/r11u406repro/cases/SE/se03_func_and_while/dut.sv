// § arrElemVarKind406
module top;
  string names [3] = '{"a", "b", "c"};
  real w [2] = '{1.5, 2.5};
  initial begin
    int i = 0;
    while (i < 3) begin
      $display(names[i]);
      i++;
    end
  end
endmodule
