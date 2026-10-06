// § forMultiInitAssign258 (two initializers in a task of an interface body over the interface's own variables)
interface bif; int i, j; logic [7:0] y;
  task automatic t(); for (i = 0, j = 2; i < 4; i++) y = j; endtask
  initial t();
endinterface
module top; bif b(); endmodule
