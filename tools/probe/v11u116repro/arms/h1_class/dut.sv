package pk;
  parameter logic [31:0] P_CAT = { 16'h0, 16'h73 };
  parameter logic [31:0] P_REP = { {25{1'b0}}, 7'h37 };
endpackage
module dut import pk::*; (input logic [31:0] x);
  class C;
    logic [31:0] m = P_CAT;
    function logic [31:0] get(); return m & P_REP; endfunction
  endclass
  C c;
  initial begin c = new; $display(c.get()); end
endmodule
