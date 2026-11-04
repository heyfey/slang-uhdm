// § defGenLhsHpBaseAnchor144
interface myif (input logic clk);
  logic vld, rdy;
  modport sub (input vld, output rdy);
endinterface
module rd #(parameter int N = 2) (myif.sub s [N-1:0], output logic [N-1:0] o);
  for (genvar i = 0; i < N; i++) begin: g
    assign o[i] = s[i].vld;
  end
endmodule
module dut (input logic clk, output logic [1:0] o);
  myif arr [2-1:0] (.clk(clk));
  rd #(2) r (.s(arr), .o(o));
endmodule
