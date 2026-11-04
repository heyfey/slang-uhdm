// § clsSpecDeclNameSpan291
class box #(int W = 8); int v; endclass
class hold;
  rand protected box #(8) p;
  local static box #(4) q;
endclass
module dut; hold h; initial h = new; endmodule
