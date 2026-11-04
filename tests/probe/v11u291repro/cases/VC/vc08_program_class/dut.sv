// § clsSpecDeclNameSpan291
class box #(int W = 8); int v; endclass
program prg;
  class hold;
    box #(8) p;
  endclass
  hold h;
  initial h = new;
endprogram
module dut; endmodule
