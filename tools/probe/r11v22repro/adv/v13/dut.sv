module m #(parameter int P = 0)(output logic [31:0] o);
  if (1) begin : gb
    assign o = (P == 0) ? 32'd11 : 32'd22;
  end
endmodule
module top(output logic [31:0] oa, output logic [31:0] ob);
  m #(.P(0)) u0(.o(oa));
  m #(.P(1)) u1(.o(ob));
endmodule
