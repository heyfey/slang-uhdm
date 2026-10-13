// § tfBodyTypedefForcesBegin304
package p;
  int q;
  task automatic t(int a);
    typedef bit [2:0] s_t;
    $display("%0d", a);
  endtask
endpackage
module top; endmodule
