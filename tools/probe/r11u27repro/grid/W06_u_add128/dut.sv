module top(output logic [127:0] o);
  if (1) begin : gb
    logic [127:0] lv;
    assign lv = 128'd2 + 128'd3;
    assign o = lv;
  end
endmodule
