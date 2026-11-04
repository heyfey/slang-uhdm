// § clsSpecDeclNameSpan291
class box #(int W = 8); int v; endclass
class hold;
  typedef box #(16) wb_t;
  wb_t w;
endclass
module dut; hold h; initial h = new; endmodule
