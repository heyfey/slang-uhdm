// § genConnOpSelIdxScope239
// a two-dimensional select and a nested operation, the index a genvar
module sub (input logic a_i, input logic b_i, output logic o);
  assign o = a_i ^ b_i;
endmodule
module top (input logic r, input logic [3:0][1:0] m, output logic [3:0] o);
  for (genvar i = 0; i < 4; i++) begin : gen_b
    sub u_s (.a_i((r & m[i][0]) | m[i][1]), .b_i(~m[i][1]), .o(o[i]));
  end
endmodule
