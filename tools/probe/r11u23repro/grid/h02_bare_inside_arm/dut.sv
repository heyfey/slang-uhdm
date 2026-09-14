package pk;
  typedef enum integer { PNone, PBal } p_e;
endpackage
module top import pk::*; #(parameter p_e P = PNone, parameter int K = 9)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
  if (1) begin : gb
    logic [31:0] lv;
    assign lv = (P != PNone) ? ~(32'hffff_ffff << s) : {31'd0, 32'd3 inside {32'd1, 32'd3}};
    assign o2 = lv;
  end
endmodule
