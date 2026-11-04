// § genConnOpSelIdxScope239
// the index named like the formal, positional connection
module sub (input logic a_i, input logic b_i, output logic o);
  assign o = a_i ^ b_i;
endmodule
module top (input logic r, input logic [3:0] a_i, output logic [3:0] o);
  for (genvar i = 0; i < 4; i++) begin : gen_b
    sub u_s (r & a_i[i], r, o[i]);
  end
endmodule
