// G: a control: the ternary parameter is overridden by the instance.
module sub #(parameter int D = 2, parameter bit [1:0][4:0] R = (D == 2) ? {5'd1, 5'd2} : {5'd3, 5'd4}) (output logic [9:0] o);
  localparam bit [1:0][4:0] XY = {5'b01111, 5'b10111};
  localparam bit [1:0][4:0] X = {5'b00011, 5'b00101};
  localparam bit [1:0][4:0] Q = (D == 2) ? XY : X;
  assign o = R ^ Q;
endmodule
module top(output logic [9:0] o);
  sub #(.R(10'd5)) u(.o(o));
endmodule
