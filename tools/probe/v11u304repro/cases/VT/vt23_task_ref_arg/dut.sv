// § tfBodyTypedefForcesBegin304
package p;
  task automatic t(ref int a);
    typedef logic [3:0] n_t;
    a = n_t'(a);
  endtask
endpackage
module top; endmodule
