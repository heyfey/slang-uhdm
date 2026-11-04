// § defGenLhsHpBaseAnchor144
interface myif (input logic clk);
  logic vld, rdy;
  modport man (output vld, input rdy);
endinterface
module driver #(parameter int N = 2) (myif.man man [N-1:0], input logic [N-1:0] v);
  for (genvar i = 0; i < N; i++) begin: g
    assign man[i].vld = v[i];
  end
endmodule
module dut (input logic clk, input logic [1:0] v);
  myif arr [2-1:0] (.clk(clk));
  driver #(2) drv (.man(arr), .v(v));
endmodule
