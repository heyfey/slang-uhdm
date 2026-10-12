// § clsSpecDeclNameSpan291
class box #(int W = 8); int v; endclass
class hold;
  box #(8) arr [2];
  box #(8) q [$];
  box #(8) d [];
endclass
module dut; hold h; initial h = new; endmodule
