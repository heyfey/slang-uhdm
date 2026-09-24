interface ifc;
  generate if (1) begin : g
    logic [31:0] lv;
    assign lv = 1'b1 ? '0 : '1;
  end endgenerate
endinterface
module dut(input logic a, output logic o);
  ifc i0();
  assign o = a;
endmodule
