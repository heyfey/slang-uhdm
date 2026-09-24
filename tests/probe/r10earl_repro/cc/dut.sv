module cchild (input logic clk_i, input logic rst_ni, input logic a, output logic o);
  assign o = a & clk_i & rst_ni;
endmodule
module cc (input logic clk_i, input logic rst_ni, input logic a, output logic o);
  cchild u_flat (.clk_i(clk_i), .rst_ni(rst_ni), .a(a), .o(o));
endmodule
