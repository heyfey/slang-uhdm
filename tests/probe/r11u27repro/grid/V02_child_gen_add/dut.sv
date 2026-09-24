module sub(output logic [31:0] o);
  if (1) begin : gb
    logic [31:0] lv;
    assign lv = 32'd2 + 32'd3;
    assign o = lv;
  end
endmodule
module top(output logic [31:0] o2);
  sub u0(.o(o2));
endmodule
