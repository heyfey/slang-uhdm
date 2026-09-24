// § multiDeclOneItem140
module top;
  task automatic t(input int v);
    int a, b, c;
    int d;
    a = v;
    d = a;
  endtask
  initial t(1);
endmodule
