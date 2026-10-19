// § tfDeclOnlyBodyBegin412
class C;
  task t1();
    int a1;
    int a2;
  endtask
  function void f1();
    int b1;
  endfunction
  task t2();
    int c1 = 1;
    int c2 = 2;
  endtask
endclass
package pk;
  task pt();
    int d1;
    logic [3:0] d2;
  endtask
endpackage
module top;
  C c;
  task t3();
    int e1 = 5;
  endtask
endmodule
