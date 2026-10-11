// § genCaReplCountInst282
module top #(parameter int W = 2) (input logic [7:0] e, output logic [7:0] y);
  struct packed { logic [3:0] f; logic [3:0] g; } s;
  assign y = s;
  if (1) begin : gi
    assign s.f = {W{e[1:0]}};
    assign s.g = '0;
  end
endmodule
