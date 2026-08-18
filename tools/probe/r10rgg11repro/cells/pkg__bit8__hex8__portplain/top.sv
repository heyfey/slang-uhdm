// r10rgg11 grid cell pkg__bit8__hex8__portplain
package pk;
  function automatic bit [7:0] f8(input bit [7:0] a);
    return a;
  endfunction

  localparam int BASE = 170;
  localparam bit [7:0] IV = 8'hab;

endpackage
module sink #(parameter int W = 8) (input logic [W-1:0] i_value);
endmodule
module top;
  function automatic bit [7:0] f8(input bit [7:0] a);
    return a;
  endfunction

  localparam int BASE = 170;
  sink #(8) u (.i_value(pk::IV));
endmodule
