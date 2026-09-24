// v11u90 vx4 -- LAW A inside a generate FOR with two iterations.
module sub (output logic [31:0] o);
  genvar gi;
  generate
    for (gi = 0; gi < 2; gi++) begin : g
      wire [31:0] w_plain = 32'd11 + gi;
      wire (strong1, weak0) [31:0] w_str = 32'd12 + gi;
    end
  endgenerate
  assign o = g[0].w_plain ^ g[1].w_plain;
endmodule
module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
