// § tfBodyTypedefForcesBegin304
package p;
  int q;
  task automatic t(int a);
    typedef bit [2:0] s_t;
    begin
      q = a;
      q = q + 1;
    end
  endtask
endpackage
module top; endmodule
