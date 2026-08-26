// v158 arm F — INSTANCE COUNT AXIS: the same rejected block in a module
// body's own generic class, with that module instantiated ONCE, TWICE and
// THREE times in one design.
module leaf8 #(parameter int ID8 = 0) (input logic clk8);
  class Cell8 #(type UU = int);
    function void tick();
      if (1) begin
        UU vv8;
        int kp8;
        vv8 = UU::wind("vv8");
        kp8 = ID8;
      end
    endfunction
  endclass
  initial begin
    int seen8;
    seen8 = ID8;
  end
endmodule

module solo8 (input logic clk8);
  class Only8 #(type UU = int);
    function void tick();
      if (1) begin
        UU ef8;
        ef8 = UU::wind("ef8");
      end
    endfunction
  endclass
endmodule

module wtop_f (input logic clk8);
  solo8            s8  (.clk8(clk8));   // ONE instance
  leaf8 #(.ID8(1)) u8a (.clk8(clk8));   // THREE instances of leaf8
  leaf8 #(.ID8(2)) u8b (.clk8(clk8));
  leaf8 #(.ID8(3)) u8c (.clk8(clk8));
endmodule
