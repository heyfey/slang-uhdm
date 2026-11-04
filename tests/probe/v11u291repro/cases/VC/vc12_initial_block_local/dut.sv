// § clsSpecDeclNameSpan291
class box #(int W = 8); int v; endclass
module dut;
  initial begin
    box #(8) l;
    l = new;
  end
endmodule
