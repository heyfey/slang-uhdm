// § tfBodyTypedefForcesBegin304
package p;
  task automatic t(input int a);
    typedef int n_t;
    fork
      #1;
    join
  endtask
endpackage
module top; endmodule
