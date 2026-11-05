// a package task with a qualified formal
package zp;
  typedef logic [7:0] zb_t;
endpackage
package ap;
  task at (input zp::zb_t a, output int o);
    o = int'(a);
  endtask
endpackage
module m;
  int r;
  initial ap::at(8'h1, r);
endmodule
