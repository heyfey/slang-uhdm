
module sink #(parameter int W = 8) (input logic [7:0] i_value);
endmodule
module wsink (input logic [15:0] i_value);
endmodule
module nsink (input logic [3:0] i_value);
endmodule
module rsink (input real i_value);
endmodule
module ssink (input string i_value);
endmodule
module twosink (input logic [7:0] a, input logic [7:0] b);
endmodule
module osink (input logic [7:0] i_value, output logic [7:0] o_value);
endmodule


module top;
  function automatic logic [7:0] f8(input logic [7:0] a); return a; endfunction
  function automatic logic [7:0] g8(input logic [7:0] a); return a; endfunction
  function automatic logic [7:0] h2(input logic [7:0] a, input logic [7:0] b); return a+b; endfunction
  if (1) begin : g
    localparam bit [7:0] IV = 8'hab;
    sink #(8) u (.i_value(f8(g8({4'h0,IV[3:0]}))));
  end
endmodule
