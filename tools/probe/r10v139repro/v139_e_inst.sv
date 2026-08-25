// r10v139 arm E — 1, 2 and 3 INSTANCES.  A parameterised module holding a
// TF-ITEM subroutine plus a package class used from each, so the elaborated
// view lists the same declarations once per instance.
package Sluicebox139;
  class Paddle139;
    function void pdFn139;
      static int aa1;
      int        bb1;
      automatic int cc1;
      string     dd1 = "d";
      aa1 = 1; bb1 = 2; cc1 = 3;
    endfunction
  endclass
endpackage

module Flume139 #(parameter int WID139 = 1) (input logic clk139);
  import Sluicebox139::*;
  function void fmFn139;
    static int  ee1;
    int         ff1;
    automatic int gg1;
    logic [WID139-1:0] hh1 = '0;
    ee1 = 1; ff1 = 2; gg1 = 3;
  endfunction
  task fmTk139;
    input int ii1;
    static string jj1 = "j";
    int          kk1;
    jj1 = "k"; kk1 = ii1;
  endtask
  initial begin
    Paddle139 pp139 = new();
    fmFn139();
    pp139.pdFn139();
  end
endmodule

module TopE139(input logic clk139);
  Flume139 #(.WID139(1)) one139 (.clk139(clk139));
  Flume139 #(.WID139(2)) two139 (.clk139(clk139));
  Flume139 #(.WID139(3)) three139 (.clk139(clk139));
endmodule
