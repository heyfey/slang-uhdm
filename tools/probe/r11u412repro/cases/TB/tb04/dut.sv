// § tfDeclOnlyBodyBegin412
module top;
  task automatic t4(input int x);
    int f1;
    int f2;
  endtask
  task t5;
    input int y;
    int g1;
    int g2;
  endtask
  function void f6;
    int h1;
    int h2;
  endfunction
endmodule
