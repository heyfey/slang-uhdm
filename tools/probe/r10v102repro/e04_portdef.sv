module e04_ch #(parameter A = 'b101, parameter B = 'h1a, parameter C = 13) (input logic i);
  localparam D = 'o17;
endmodule
module e04;
  logic w;
  e04_ch #(.B('hFF)) u1(.i(w));
endmodule
