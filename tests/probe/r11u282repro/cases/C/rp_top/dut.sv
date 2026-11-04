// § genCaReplCountInst282
module top #(parameter int P = 4) (input logic [7:0] b, output logic [7:0] z);
  if (1) begin : g
    assign z = {P{b[0]}};
  end
endmodule

