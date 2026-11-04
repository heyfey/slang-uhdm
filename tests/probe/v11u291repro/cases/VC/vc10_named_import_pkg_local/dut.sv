// § clsSpecDeclNameSpan291
package q; class box #(int W = 8); int v; endclass endpackage
package p;
  import q::box;
  class hold;
    box #(8) p;
    task t();
      box #(3) l;
      l = null;
    endtask
  endclass
endpackage
module dut; p::hold h; initial h = null; endmodule
