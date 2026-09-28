module sm (input logic in);
  always @(posedge in) begin : kb
    logic hold;
    hold = in;
  end
endmodule
module top (input logic a);
  vm u1 (a);
  sm u2 (a);
endmodule
