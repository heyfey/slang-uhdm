// § ifaceElabInlineSuKeyword130
interface bus #(parameter W = 4);
  struct packed { logic [W-1:0] a; logic b; } s;
  assign s = '0;
endinterface
module top;
  for (genvar i = 0; i < 2; i++) begin : g
    bus #(.W(i+2)) b();
  end
endmodule
