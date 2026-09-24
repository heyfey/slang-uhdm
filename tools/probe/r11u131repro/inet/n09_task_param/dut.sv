// § implicitNetMintNoFile131
module top(output int o);
  task automatic t(output int y);
    parameter int P = 5;
    y = P;
  endtask
  initial t(o);
endmodule
