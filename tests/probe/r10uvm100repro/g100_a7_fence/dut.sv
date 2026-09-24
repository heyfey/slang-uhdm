// r10uvm100 arm a7 -- THE FENCE: every spelling this pass must leave EXACTLY
// as it was -- non-parenthesised statement delays, all intra-assignment
// delays, and the number forms.
module m7a;
  parameter Tp7 = 3;
  int a7, b7;
  task automatic tk7;
    #Tp7 a7 = 1;
    #5 a7 = 2;
    #1ns a7 = 3;
    #10ps a7 = 4;
  endtask
  initial begin
    b7 <= #Tp7 1;
    b7 <= #5 2;
    b7 <= #(Tp7) 3;
    b7 <= #(Tp7 + 1) 4;
    #Tp7 b7 = 5;
  end
endmodule
