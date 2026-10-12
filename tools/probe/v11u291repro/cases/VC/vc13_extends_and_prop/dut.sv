// § clsSpecDeclNameSpan291
class box #(int W = 8); int v; endclass
class base; endclass
class hold extends base;
  box #(8) p, r;
  box #() s;
endclass
module dut; hold h; initial h = new; endmodule
