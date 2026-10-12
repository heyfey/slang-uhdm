// § modEnumTfArgCloneFollows299
module m (input logic [1:0] d, output logic o);
  typedef enum logic [1:0] { BA, BB, BC } b_e;
  localparam b_e LP = BB;
  assign o = (b_e'(d) == LP);
endmodule
module top (input logic [1:0] d, output logic o);
  m u (.d(d), .o(o));
endmodule
