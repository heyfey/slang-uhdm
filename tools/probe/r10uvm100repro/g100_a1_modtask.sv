// r10uvm100 arm a1 -- every delay spelling, STATEMENT and INTRA-ASSIGNMENT,
// in a module task and a module initial block.  No macros anywhere.
module m1a;
  parameter Tp = 3;
  int a, b;
  task automatic tk;
    #(Tp) a = 1;
    #(Tp+1) a = 2;
    #Tp a = 3;
    #5 a = 4;
    #(5) a = 5;
    #1ns a = 6;
    #(1ns) a = 7;
    #(Tp*2+1) a = 8;
  endtask
  initial begin
    #(Tp) b = 1;
    #Tp b = 2;
    #7 b = 3;
    b <= #(Tp) 1;
    b <= #Tp 2;
    b <= #(Tp+1) 3;
    b <= #9 4;
    b <= #(9) 5;
  end
  always #(Tp) a = a + 1;
  always #Tp b = b + 1;
endmodule
