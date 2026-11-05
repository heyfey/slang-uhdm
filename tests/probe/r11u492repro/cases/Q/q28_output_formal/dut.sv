// an output formal and a ref formal in a task
package zp;
  typedef logic [7:0] zb_t;
endpackage
package ap;
  task at (output zp::zb_t o, input int i);
    o = zp::zb_t'(i);
  endtask
endpackage
module m;
  logic [7:0] r;
  initial ap::at(r, 3);
endmodule
