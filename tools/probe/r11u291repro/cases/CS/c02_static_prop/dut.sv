// § clsSpecDeclNameSpan291
class box #(int W = 8); int v; endclass
class hold;
  static box #(8) p;
endclass
module dut; hold h; initial h = new; endmodule
