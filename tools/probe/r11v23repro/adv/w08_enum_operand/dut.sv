module dut(input logic a, output logic [31:0] o);
  typedef enum logic [3:0] {E1=3, E2=4} e_t;
  generate if (1) begin : g
    logic [31:0] lv;
    assign lv = 1'b1 ? {E1, E1} : 32'd0;
    assign o = lv;
  end endgenerate
endmodule
