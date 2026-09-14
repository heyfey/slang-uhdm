package pk;
  typedef enum integer { PNone, PBal } p_e;
endpackage
module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2,
   output logic [31:0] o3, output logic [7:0] o8);
  if (1) begin : gb
    assign o2 = (P != PNone) ? ~(32'hffff_ffff << s) : '0;
    assign o3 = (P != PNone) ? a : (32'd2 ^ 32'd3);
    assign o8 = (P != PNone) ? a[7:0] : '0;
  end
endmodule
