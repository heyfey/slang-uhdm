// § multiDeclOneItem140
module top;
  task automatic t(input int x);
    int i, j;
    i = x;
    j = i;
    $display("%0d", j);
  endtask
  initial t(3);
endmodule
