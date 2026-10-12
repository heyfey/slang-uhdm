// § clsSpecDeclNameSpan291
class box #(int W = 8, int D = 2); int v; endclass
class hold;
  box #(
    .W(16),
    .D(3)
  ) p;
endclass
module dut; hold h; initial h = new; endmodule
