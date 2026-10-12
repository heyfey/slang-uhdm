// § clsSpecDeclNameSpan291
class box #(int W = 8); int v; endclass
class hold;
  box #(8) p = new;
endclass
module dut; hold h; initial h = new; endmodule
