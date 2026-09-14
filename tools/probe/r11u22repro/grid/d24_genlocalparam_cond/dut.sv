package pk;
  typedef enum integer { PNone, PBal } p_e;
endpackage
module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [31:0] o2);
  if (1) begin : gb
    localparam int LQ = 0;
    assign o2 = (LQ != 0) ? ~(32'hffff_ffff << s) : '0;
  end
endmodule
