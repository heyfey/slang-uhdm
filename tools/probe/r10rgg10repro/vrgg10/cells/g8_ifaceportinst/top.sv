
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


interface pif #(parameter int W = 8) (input logic [7:0] i_value); endinterface
module top;
  if (1) begin : g
    localparam bit [7:0] IV = 8'hab;
    pif #(8) p (.i_value(IV));
  end
endmodule
