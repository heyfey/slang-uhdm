// § genConnOpSelIdxScope239
// a generate block inside a non-top module, two instances, the index a port of that module
module sub (input logic a_i, input logic b_i, output logic o);
  assign o = a_i ^ b_i;
endmodule
module mid (input logic r, input logic [1:0] k, input logic [3:0] v, output logic [1:0] o);
  for (genvar i = 0; i < 2; i++) begin : gen_b
    sub u_s (.a_i(r & v[k]), .b_i(v[i] | r), .o(o[i]));
  end
endmodule
module top (input logic r, input logic [1:0] k, input logic [3:0] v, output logic [3:0] o);
  mid m0 (.r(r), .k(k), .v(v), .o(o[1:0]));
  mid m1 (.r(~r), .k(k), .v(v), .o(o[3:2]));
endmodule
