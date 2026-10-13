// § tfBodyTypedefForcesBegin304
interface ifc;
  int q;
  task automatic t(int x);
    typedef bit [2:0] s_t;
    q = x;
  endtask
endinterface
module top; ifc u(); endmodule
