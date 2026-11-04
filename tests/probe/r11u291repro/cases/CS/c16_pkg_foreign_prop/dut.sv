// § clsSpecDeclNameSpan291
package q; class box #(int W = 8); int v; endclass endpackage
package p; import q::*;
class hold;
  box #(8) p;
endclass
endpackage
module dut; p::hold h; initial h = null; endmodule
