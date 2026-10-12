// § rawEndLineModel295
module top(output logic [7:0] o);
  function automatic logic [7:0] f(input logic [7:0] x); return x; endfunction
  logic [7:0] a = f(
    8'h3); logic \z.z ;
  assign o = a;
endmodule
