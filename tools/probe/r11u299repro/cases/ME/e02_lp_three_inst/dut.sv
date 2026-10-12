// § modEnumTfArgCloneFollows299
module m #(parameter int W = 4) (input logic [1:0] d, output logic o);
  typedef enum logic [1:0] { BA, BB, BC } b_e;
  localparam b_e LP = BB;
  parameter b_e PP = BC;
  function automatic logic f(input b_e q); return q == BA; endfunction
  assign o = f(b_e'(d)) ^ (LP == PP);
endmodule
module top (input logic [1:0] d, output logic [2:0] o);
  m #(.W(4)) u_a (.d(d), .o(o[0]));
  m #(.W(8)) u_b (.d(d), .o(o[1]));
  m #(.W(16)) u_c (.d(d), .o(o[2]));
endmodule
