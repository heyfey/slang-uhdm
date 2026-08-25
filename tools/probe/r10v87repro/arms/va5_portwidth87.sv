// r10v87 arm va5 — the colliding package member is used ONLY in a PORT WIDTH
// and in a GENERATE-IF condition (never in an expression body).
package pw5;
  localparam int WA = 4;
  localparam int WB = 1;
endpackage

module wleaf #(parameter int WA = 2, parameter int WC = 1)
              (input logic [WA-1:0] i, output logic [7:0] o);
  import pw5::*;
  if (WB == 1) begin : g_on
    assign o = {{(8-WA){1'b0}}, i} + WC[7:0];
  end
  else begin : g_off
    assign o = 8'd0;
  end
endmodule

module top87 (input logic [7:0] i, output logic [7:0] o1, o2);
  wleaf #(.WA(6)) u_w (.i(i[5:0]), .o(o1));
  wleaf           u_n (.i(i[1:0]), .o(o2));
endmodule
