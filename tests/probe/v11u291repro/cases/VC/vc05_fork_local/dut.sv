// § clsSpecDeclNameSpan291
class box #(int W = 8); int v; endclass
class hold;
  task t();
    fork
      begin
        box #(8) l;
        l = null;
      end
    join
  endtask
endclass
module dut; hold h; initial h = new; endmodule
