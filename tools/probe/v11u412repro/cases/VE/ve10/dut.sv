// § enumXzReplInitZero412
module top(output logic [1:0] o);
  typedef enum logic [1:0] {A = {2{1'b0}}, B = 2'b01, Z = {2{1'bz}}} e_t;
  e_t v;
  assign v = A;
  assign o = v;
endmodule
