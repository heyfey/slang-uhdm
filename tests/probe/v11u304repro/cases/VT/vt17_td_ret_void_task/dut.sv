// § tfBodyTypedefForcesBegin304
package p;
  task automatic t(output int a);
    typedef int n_t;
    a = 5;
  endtask
endpackage
module top; endmodule
