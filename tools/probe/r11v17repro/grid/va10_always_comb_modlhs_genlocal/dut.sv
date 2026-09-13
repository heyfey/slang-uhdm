// PROCESS driver in the gen scope writing a module-level name: LAW 2 is a
// cont_assign law and must not touch this.
module top(input logic [31:0] a, output logic [31:0] o);
  logic [31:0] mv;
  if (1) begin : gb
    logic [31:0] src;
    assign src = a;
    always_comb mv = src | 32'd1;
  end
  assign o = mv;
endmodule
