// § varInitOpCastKept404
package pk; int pv = 2 + 3; endpackage
class K; int cv = 4 + 5; endclass
module top;
  task automatic t; int tv = 6 + 7; $display(tv); endtask
  initial begin int iv = 8 + 9; $display(iv, pk::pv); end
endmodule
