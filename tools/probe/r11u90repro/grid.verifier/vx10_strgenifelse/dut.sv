// v11u90 vx10 -- generate IF, both branches carry a strength net.
module sub #(parameter int P = 1) (output logic [31:0] o);
  generate
    if (P == 1) begin : g
      wire [31:0] w_plain = 32'd11;
      wire (strong1, weak0) [31:0] w_str = 32'd12;
    end
    else begin : g
      wire [31:0] w_plain = 32'd21;
      wire (weak1, strong0) [31:0] w_str = 32'd22;
    end
  endgenerate
  assign o = g.w_plain;
endmodule
module dut (output logic [31:0] o);
  sub #(.P(1)) u_s (.o(o));
endmodule
