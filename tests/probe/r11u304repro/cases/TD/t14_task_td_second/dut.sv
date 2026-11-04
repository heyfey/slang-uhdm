// § tfBodyTypedefIsItem304
package p;
  int q;
  task automatic t(int a);
    int b;
    typedef bit [2:0] s_t;
    s_t v;
    v = a[2:0];
    q = v + b;
  endtask
endpackage
module top; endmodule
