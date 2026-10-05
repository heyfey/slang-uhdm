// § genConnOpSelIdxScope239
module sub (input logic a_i, output logic o);
  assign o = a_i;
endmodule
module top (input logic r, input logic [1:0] k, input logic [3:0] v, output logic [3:0] o);
  for (genvar i = 0; i < 4; i++) begin : gen_b
    sub u_s (.a_i(r & v[k]), .o(o[i]));
  end
endmodule
