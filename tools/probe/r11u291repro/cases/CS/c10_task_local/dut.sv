// § clsSpecDeclNameSpan291
class box #(int W = 8); int v; endclass
module dut;
  task t();
    box #(4) l;
    l = null;
  endtask
  initial t();
endmodule
