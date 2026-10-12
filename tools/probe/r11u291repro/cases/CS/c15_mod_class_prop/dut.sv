// § clsSpecDeclNameSpan291
module dut;
  class box #(int W = 8); int v; endclass
  class hold;
    box #(8) p;
  endclass
  hold h;
  initial h = new;
endmodule
