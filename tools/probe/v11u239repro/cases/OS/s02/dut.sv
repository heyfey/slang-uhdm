// § genConnOpSelIdxScope239
// a generate-local localparam index, an unnamed generate block
module sub (input logic a_i, input logic b_i, output logic o);
  assign o = a_i ^ b_i;
endmodule
module top (input logic r, input logic [3:0] v, output logic [3:0] o);
  for (genvar i = 0; i < 4; i++) begin
    localparam int J = 3 - i;
    sub u_s (.a_i(r | v[J]), .b_i(r), .o(o[i]));
  end
endmodule
