// r10v95 -- adversarial arm F: a BIND instance whose own generate scopes are
// elaborated into a foreign hierarchy.
module btgt95 (input logic [31:0] din, output logic [7:0] o);
  assign o = din[7:0];
endmodule

module bmon95 #(parameter int W = 8) (input logic [31:0] din);
  localparam int BP = 3;
  localparam logic [63:0] BTBL [0:7] = '{64'd0,64'd1,64'd2,64'd3,64'd4,64'd5,64'd6,64'd7};
  logic [7:0] y1, y2;
  if (W > 0) begin : b_d1
    assign y1 = BTBL[BP-1][7:0];
    if (W > 0) begin : b_d2
      assign y2 = BTBL[BP-1][7:0];
    end
  end
endmodule

module v95f_bind (input logic [31:0] din, output logic [7:0] o);
  btgt95 u_t (.din(din), .o(o));
  bind btgt95 bmon95 #(.W(8)) u_mon (.din(din));
endmodule
