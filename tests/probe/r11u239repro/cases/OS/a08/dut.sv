// § genConnOpSelIdxScope239
module sub (input logic a_i, output logic o);
  assign o = a_i;
endmodule
module top (input logic r, input logic [3:0] v, input logic [1:0] k, output logic [3:0] o);
  if (1) begin : gen_b
    sub u_s (.a_i(r | v[k]), .o(o[0]));
  end
endmodule
