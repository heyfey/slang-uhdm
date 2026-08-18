// v65 ARM 3 — HOMES: module body / gen-for / gen-if / nested module /
// interface, 1..3 instances of the same shape.  MEASUREMENT ONLY.
package pa3;
  localparam int PW = 5;
  localparam int PB = 2;
endpackage

interface if3 (input logic clk);
  logic [63:0] bus;
  modport mp (input bus);
endinterface

module l3 (input logic [31:0] a_i, input logic b_i, output logic o_o);
  assign o_o = ^a_i ^ b_i;
endmodule

module mid3 import pa3::*; (input logic [63:0] d_i, output logic [1:0] o_o);
  l3 u_n1 (.a_i(d_i[0  +: PW]), .b_i(d_i[0]), .o_o(o_o[0]));
  l3 u_n2 (.a_i(d_i[PB +: 32]), .b_i(d_i[0]), .o_o(o_o[1]));
endmodule

module ifuse3 import pa3::*; (if3.mp p, output logic o_o);
  l3 u_i1 (.a_i(p.bus[0 +: PW]), .b_i(p.bus[0]), .o_o(o_o));
endmodule

module a3_home import pa3::*; (input logic clk, input logic [63:0] d_i,
                               output logic [15:0] o_o);
  // module body, THREE instances of the identical shape
  l3 u_m1 (.a_i(d_i[0 +: PW]), .b_i(d_i[0]), .o_o(o_o[0]));
  l3 u_m2 (.a_i(d_i[0 +: PW]), .b_i(d_i[0]), .o_o(o_o[1]));
  l3 u_m3 (.a_i(d_i[0 +: PW]), .b_i(d_i[0]), .o_o(o_o[2]));
  // gen-for
  for (genvar i = 0; i < 3; i++) begin : gfor
    l3 u_g (.a_i(d_i[i*8 +: PW]), .b_i(d_i[PB]), .o_o(o_o[3+i]));
  end
  // gen-if, both arms present in the source
  if (PW == 5) begin : gif
    l3 u_t (.a_i(d_i[0 +: PW]), .b_i(d_i[0]), .o_o(o_o[6]));
  end else begin : gif
    assign o_o[6] = 1'b0;
  end
  // nested gen-for inside gen-if
  if (PW == 5) begin : gnest
    for (genvar j = 0; j < 2; j++) begin : gin
      l3 u_n (.a_i(d_i[0 +: PW]), .b_i(d_i[0]), .o_o(o_o[7+j]));
    end
  end
  // nested module instance
  mid3 u_mid (.d_i(d_i), .o_o(o_o[10:9]));
  // interface home
  if3 the_if (.clk(clk));
  assign the_if.bus = d_i;
  ifuse3 u_ifu (.p(the_if.mp), .o_o(o_o[11]));
  // instance ARRAY
  l3 u_arr [1:0] (.a_i({27'b0, d_i[0 +: PW]}), .b_i(d_i[0]), .o_o(o_o[13:12]));
  assign o_o[15:14] = 2'b0;
endmodule
