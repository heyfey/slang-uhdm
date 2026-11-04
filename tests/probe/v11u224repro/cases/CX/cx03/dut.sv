// § strLitContOwnerEnd224
module top(input string s, output int o);
  always_comb begin
    if (s == "ab \
cd") o = 1;
    else o = 0;
  end
endmodule
