// § clsSpecDeclNameSpan291
class box #(int W = 8); int v; endclass
interface ifc;
  class hold;
    box #(8) p;
  endclass
  hold h;
  initial h = new;
endinterface
module dut; ifc i (); endmodule
