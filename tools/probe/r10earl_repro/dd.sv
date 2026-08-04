module dchild (input logic clk_i, input logic rst_ni, input logic a, output logic o);
  assign o = a & clk_i & rst_ni;
endmodule
module dd (input logic clk_i, input logic rst_ni, input logic a, output logic o);
  dchild u_flat (.clk_i, .rst_ni, .a(a), .o(o));
endmodule
