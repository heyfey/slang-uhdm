// § ovUntypedTsDeclWidth427
module cc #(parameter count_negedge_p = 0, parameter use_p = 0, parameter W = 8, parameter D = -1)(input a, output o);
  assign o = a ^ count_negedge_p[0] ^ use_p[0] ^ W[0] ^ D[0];
endmodule
module top(input a, output [3:0] o);
  cc #(.count_negedge_p(1'b1), .use_p(1'b0)) u1(.a(a), .o(o[0]));
  cc #(1'b0, 1'b1) u2(.a(a), .o(o[1]));
  cc #(.W(4'b1001), .D('d0)) u3(.a(a), .o(o[2]));
  cc u4(.a(a), .o(o[3]));
endmodule
