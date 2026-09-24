module sub(output logic [31:0] q);
  if (1) begin : gb
    logic [31:0] lv;
    assign lv = '0;
    assign q = lv;
  end
endmodule
module top(output logic [31:0] o2);
  sub u(.q(o2));
endmodule
