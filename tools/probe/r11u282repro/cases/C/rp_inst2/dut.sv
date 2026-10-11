// § genCaReplCountInst282
module top #(parameter int P = 4) (input logic [7:0] b, output logic [7:0] z);
  if (1) begin : g
    assign z = {P{b[0]}};
  end
endmodule
module wrap(input logic [7:0] b, output logic [7:0] z, output logic [7:0] y); top #(.P(5)) u (.b(b), .z(z)); top #(.P(6)) v (.b(b), .z(y)); endmodule
