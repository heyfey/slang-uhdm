module top(output logic [127:0] o);
  if (1) begin : gb
    logic [127:0] lv;
    assign lv = 128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF;
    assign o = lv;
  end
endmodule
