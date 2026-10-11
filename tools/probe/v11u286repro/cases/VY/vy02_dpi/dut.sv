// § genProcLvIdxCallSpan286
module top;
  import "DPI-C" function int dfn(int a);
  logic [7:0] v;
  if (1) begin : gi
    initial v[dfn(1)] = 1'b1;
  end
endmodule
