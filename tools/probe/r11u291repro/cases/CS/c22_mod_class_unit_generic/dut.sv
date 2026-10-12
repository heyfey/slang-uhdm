// § clsSpecDeclNameSpan291
class box #(int W = 8); int v; endclass
module dut;
  class hold;
    box #(8) p;
  endclass
  hold h;
  initial h = new;
endmodule
