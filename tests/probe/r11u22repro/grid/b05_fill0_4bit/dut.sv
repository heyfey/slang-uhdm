package pk;
  typedef enum integer { PNone, PBal } p_e;
endpackage
module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [3:0] o4);
  if (1) begin : gb
    assign o4 = (P != PNone) ? ~(4'hf << s) : '0;
  end
endmodule
