interface ifc;
  if (1) begin : gb
    logic [31:0] lv;
    assign lv = '0;
  end
endinterface
module top(output logic [31:0] o2);
  ifc u();
  assign o2 = u.gb.lv;
endmodule
