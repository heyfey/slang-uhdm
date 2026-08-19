// r10uvm100 arm a4 -- the HOMES axis: package task, program, interface task,
// forever/repeat/while bodies, a generate block, a function (delays are legal
// only in a task, so functions carry none).
package p4a;
  int t4 = 2;
  task automatic pt4;
    #(t4) t4 = t4 + 1;
    #t4 t4 = t4 + 1;
  endtask
endpackage
interface if4a;
  int w4;
  task automatic it4(int d);
    #(d) w4 = 1;
  endtask
endinterface
program pg4a;
  int z4;
  initial begin
    #(3) z4 = 1;
    #3 z4 = 2;
  end
endprogram
module m4a;
  import p4a::*;
  int c4;
  if4a u4();
  initial begin
    repeat (2) #(t4) c4 = c4 + 1;
    while (c4 < 4) #(t4 + 1) c4 = c4 + 1;
  end
  initial forever #(t4) c4 = ~c4;
  generate
    if (1) begin : g4
      initial #(t4) c4 = 9;
    end
  endgenerate
endmodule
