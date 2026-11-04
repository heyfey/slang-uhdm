// § strNetRefMintsNet422
module sub ();
  module innermod (input logic [3:0] a, output logic [3:0] y);
    wire (weak0, weak1) [1:0] u = a[1:0];
    assign y = {2'b0, u};
  endmodule
endmodule
module top;
  sub u_s ();
endmodule
