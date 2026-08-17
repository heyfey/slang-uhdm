interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
module leaf_w6 #(parameter int R = 4)(input logic clk);
  function automatic int f(input int a [R]); return a[0]; endfunction
  task automatic t(input int b [R]); endtask
endmodule
module top;
  logic clk;
  leaf_w6 #(.R(6)) u (clk);
endmodule
