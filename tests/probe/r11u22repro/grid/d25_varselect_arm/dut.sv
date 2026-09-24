package pk;
  typedef enum integer { PNone, PBal } p_e;
endpackage
module top import pk::*; #(parameter p_e P = PNone)
  (input logic [31:0] a, input logic [4:0] s, output logic [7:0] o8);
  logic [3:0][7:0] mem;
  assign mem = {a};
  if (1) begin : gb
    assign o8 = (P == PNone) ? mem[1] : '0;
  end
endmodule
