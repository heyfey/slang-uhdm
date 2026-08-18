
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
  if (1) begin : a if (1) begin : b if (1) begin : c if (1) begin : d
    localparam bit [7:0] IV = 8'hab;
    if (1) begin : e sink #(8) u (.i_value(IV)); end
  end end end end
endmodule
