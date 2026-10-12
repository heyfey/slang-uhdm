// § clsSpecDeclNameSpan291
class box #(int W = 8); int v; endclass
program prg;
  task t();
    box #(4) l;
    l = null;
  endtask
  initial t();
endprogram
module dut; endmodule
