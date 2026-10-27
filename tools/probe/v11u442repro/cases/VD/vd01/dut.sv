// § modDynTdDefNetCopy442
module top;
  typedef int d_t [];
  d_t a;
  task automatic t();
    d_t loc;
    loc = new[2];
  endtask
endmodule
