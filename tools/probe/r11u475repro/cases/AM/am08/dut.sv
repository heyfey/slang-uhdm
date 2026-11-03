// § addOperandConstMint475
// a module's own and a generate-block localparam adding a 'd literal, and a child override
module sub #(parameter logic [7:0] P = 8'd3, parameter logic [7:0] Q = P + 8'd1) (output logic [7:0] o);
  assign o = Q;
endmodule
module top(output logic [7:0] y, output logic [7:0] z);
  parameter logic [7:0] A = 8'd9;
  localparam logic [7:0] B = A + 1;
  if (1) begin : g
    localparam logic [7:0] C = B + 8'd2;
    assign z = C;
  end
  sub #(.P(B)) u(.o(y));
endmodule
