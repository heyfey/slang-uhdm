// § genConnOpSelIdxScope239
// (pass 236 decode g01, Earlgrey #121994)
module sub (input logic a_i, input logic b_i, output logic o);
  assign o = a_i ^ b_i;
endmodule
module top (input logic r, input logic [3:0] v, output logic [3:0] o);
  for (genvar i = 0; i < 4; i++) begin : gen_b
    sub u_s (.a_i(r & v[i]), .b_i(v[i]), .o(o[i]));
  end
endmodule
