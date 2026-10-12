// § modEnumTfArgCloneFollows299
module m (input logic [1:0] d, output logic o);
  typedef enum logic [1:0] { BA, BB, BC } b_e;
  function automatic logic f(input b_e q); return q == BA; endfunction
  if (1) begin : g
    localparam b_e GLP = BB;
    assign o = f(b_e'(d)) ^ (GLP == BC);
  end
endmodule
module top (input logic [1:0] d, output logic o);
  m u (.d(d), .o(o));
endmodule
