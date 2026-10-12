// § clsSpecDeclNameSpan291
class inner #(int W = 1); int v; endclass
class box #(type T = int); T v; endclass
class hold;
  box #(inner #(4)) p;
endclass
module dut; hold h; initial h = new; endmodule
