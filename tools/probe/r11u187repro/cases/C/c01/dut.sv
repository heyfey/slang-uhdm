// § blockSizeDimEndsAtExpr183
module top #(parameter int N = 3) (output int o);
  task automatic t(output int r);
    begin
      int q[N];
      q[0] = 2;
      r = q[0];
    end
  endtask
  initial t(o);
endmodule
