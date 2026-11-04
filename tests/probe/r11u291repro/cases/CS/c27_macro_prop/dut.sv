// § clsSpecDeclNameSpan291
class box #(int W = 8); int v; endclass
`define PROP(n) box #(8) n;
class hold;
  `PROP(p)
endclass
module dut; hold h; initial h = new; endmodule
