// § genConnOpSelIdxScope239
// an indexed part-select and a concatenation actual
module sub (input logic [1:0] a_i, output logic o);
  assign o = ^a_i;
endmodule
module top (input logic r, input logic [7:0] v, output logic [3:0] o);
  for (genvar i = 0; i < 4; i++) begin : gen_b
    sub u_s (.a_i({r, v[i]} & v[i*2 +: 2]), .o(o[i]));
  end
endmodule
