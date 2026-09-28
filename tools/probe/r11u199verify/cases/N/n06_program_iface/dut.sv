// § nestedDefChainName193
module sub (input logic [7:0] x);
  program np (input logic [7:0] a);
    logic [7:0] m;
    logic [3:0] h;
    initial begin
      m = a;
      h = m[7:4];
    end
  endprogram
  logic [7:0] w;
  assign w = x;
endmodule
module dut (input logic [7:0] x, output logic [7:0] o);
  sub u_s (.x(x));
  assign o = x;
endmodule
