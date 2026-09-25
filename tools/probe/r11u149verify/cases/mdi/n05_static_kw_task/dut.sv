// § multiDeclOneItem140
module dut;
  task automatic t(input int v);
    static int a = 1, b = 2;
    a = v + b;
  endtask
  initial t(3);
endmodule
