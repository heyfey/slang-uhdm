// r10rgg11 grid cell genif__untyped__unsized__portplain
module sink #(parameter int W = 8) (input logic [W-1:0] i_value);
endmodule
module top;
  function automatic bit [7:0] f8(input bit [7:0] a);
    return a;
  endfunction

  if (1) begin : g
    localparam int BASE = 170;
  localparam IV = 171;
    sink #(8) u (.i_value(IV));
  end
endmodule
