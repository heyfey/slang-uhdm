// § nestedDefChainName193
module sub ();
  module innermod (input logic [3:0] a, output logic [3:0] r);
    function automatic logic [3:0] f(input logic [3:0] x);
      return x + 4'd1;
    endfunction
    logic [3:0] t;
    assign t = a;
    assign r = f(t);
  endmodule
  wire [3:0] q = 4'd1;
endmodule
module dut (output logic [3:0] o);
  sub u_s ();
  assign o = 4'd0;
endmodule
