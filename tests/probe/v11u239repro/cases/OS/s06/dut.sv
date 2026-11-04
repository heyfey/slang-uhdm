// § genConnOpSelIdxScope239
// nested for blocks, the inner genvar indexing a struct-array member
typedef struct packed { logic a; logic b; } s_t;
module sub (input logic a_i, input logic b_i, output logic o);
  assign o = a_i ^ b_i;
endmodule
module top (input logic r, input s_t [3:0] v, output logic [3:0] o);
  for (genvar i = 0; i < 2; i++) begin : ga
    for (genvar j = 0; j < 2; j++) begin : gb
      sub u_s (.a_i(r & v[j].a), .b_i(v[i].b ^ r), .o(o[i*2+j]));
    end
  end
endmodule
