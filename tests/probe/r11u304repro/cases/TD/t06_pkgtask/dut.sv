// § tfBodyTypedefIsItem304
package p;
  int q;
  task automatic t(int a);
    typedef bit [2:0] s_t;
    s_t v;
    v = a[2:0];
    q = v;
  endtask
endpackage
module top; endmodule
