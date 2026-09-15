// r11u46 GRID-3 — the REMAINING def-view emitSyntaxExpr positions for a
// signing cast: parameter defaults, port connections, unpacked dims,
// concatenations, call arguments, and continuous assigns inside a def-view
// generate block.
module leaf #(parameter int unsigned W = 4) (input logic [7:0] a_i, output logic [7:0] y_o);
  assign y_o = a_i;
endmodule

module grid3 #(
    parameter int unsigned N  = 4,
    // U: a signing cast in a module PARAMETER DEFAULT
    parameter int unsigned NU = unsigned'(4)
) (
    input  logic [7:0] in_i,
    output logic [7:0] out_o
);
  localparam int unsigned M = 3;

  // V: a signing cast in a def-view instance PORT CONNECTION width
  logic [7:0] vwire;
  leaf #(.W(unsigned'(M))) u_leaf (.a_i(in_i), .y_o(vwire));

  // W: a signing cast in an UNPACKED dimension
  logic [7:0] warr [unsigned'(M)];

  // X: a signing cast inside a CONCATENATION in a def-view gen-block assign
  if (N > 0) begin : g_x
    assign out_o = {4'b0, unsigned'(M[3:0])};
  end

  // Y: a signing cast as a FUNCTION-CALL argument in a def-view gen-block
  function automatic int unsigned twice(input int unsigned v);
    twice = v * 2;
  endfunction
  if (N > 0) begin : g_y
    localparam int unsigned YY = twice(unsigned'(M));
    assign out_o[0] = in_i[YY[0]];
  end

  // Z: a signing cast in a def-view gen-block CONTINUOUS ASSIGN rhs
  if (N > 0) begin : g_z
    assign out_o[1] = in_i[unsigned'(M)];
  end
endmodule

module grid3top (input logic [7:0] i_i, output logic [7:0] o_o);
  grid3 #(.N(4)) u (.in_i(i_i), .out_o(o_o));
endmodule
