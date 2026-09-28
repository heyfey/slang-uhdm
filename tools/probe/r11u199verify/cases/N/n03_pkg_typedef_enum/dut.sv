// § nestedDefChainName193 § nestChainKeepsPkgQual193v
package pk;
  typedef enum logic [1:0] { A, B, C } e_t;
  typedef logic [3:0] w_t;
endpackage
module sub (input logic [1:0] x);
  module inner (input logic [1:0] s, output pk::w_t q);
    pk::e_t st;
    assign st = pk::e_t'(s);
    assign q = (st == pk::B) ? 4'd1 : (st == pk::C ? 4'd2 : 4'd0);
  endmodule
  pk::w_t r;
  assign r = {2'b0, x};
endmodule
module dut (input logic [1:0] x, output logic [1:0] o);
  sub u_s (.x(x));
  assign o = x;
endmodule
