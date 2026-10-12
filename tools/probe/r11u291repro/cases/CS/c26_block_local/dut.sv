// § clsSpecDeclNameSpan291
class box #(int W = 8); int v; endclass
module dut;
  initial begin
    box #(4) l;
    l = null;
  end
endmodule
