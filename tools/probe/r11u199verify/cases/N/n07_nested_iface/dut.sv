// § nestedDefChainName193
module sub (input logic [7:0] x);
  interface nif;
    logic [7:0] d;
    logic [3:0] h;
    assign h = d[7:4];
  endinterface
  logic [7:0] w;
  assign w = x;
endmodule
module dut (input logic [7:0] x, output logic [7:0] o);
  sub u_s (.x(x));
  assign o = x;
endmodule
