// § defConnIpsFoldTsOwner236 — indexed part selects with package bases and widths in port connections: -:, an operation base, depth three, two connections
package pk;
  localparam int W = 4;
  localparam int B = 2;
  localparam int H = 11;
endpackage
module sub #(parameter int SW = 4) (input logic [SW-1:0] a_i, input logic [SW-1:0] b_i, output logic o);
  assign o = ^(a_i ^ b_i);
endmodule
module mid (input logic [15:0] x, output logic o, output logic o2);
  sub u_s (.a_i(x[pk::H -: pk::W]), .b_i(x[pk::B * 2 +: pk::W]), .o(o));
  sub #(.SW(pk::W)) u_t (.a_i(x[pk::B +: pk::W]), .b_i(x[pk::W +: pk::W]), .o(o2));
endmodule
module mid2 (input logic [15:0] x, output logic o, output logic o2);
  mid u_m (.x(x), .o(o), .o2(o2));
endmodule
module top (input logic [15:0] x, output logic o, output logic o2);
  mid2 u_m2 (.x(x), .o(o), .o2(o2));
endmodule
