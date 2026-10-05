// § genConnOpSelIdxScope239
// a case-generate item and a nested for, the index a parameter
module sub (input logic a_i, output logic o);
  assign o = a_i;
endmodule
module top #(parameter int P = 1, parameter int K = 2) (input logic r, input logic [3:0] v, output logic [3:0] o);
  case (K)
    2: begin : gc
      sub u_s (.a_i(r & v[P]), .o(o[0]));
    end
    default: begin : gd
      sub u_s (.a_i(r), .o(o[0]));
    end
  endcase
  for (genvar i = 0; i < 2; i++) begin : ga
    for (genvar j = 0; j < 2; j++) begin : gb
      sub u_t (.a_i(v[i] | v[j]), .o(o[i*2+j]));
    end
  end
endmodule
