// § callArgParamCopyOwnTs246
class C #(int W = 4);
  bit [W-1:0] v;
  static function int sz(); return W; endfunction
endclass
module sub #(parameter int N = 4) (output logic [N-1:0][7:0] o);
  function automatic bit [N-1:0][7:0] f(int n);
    bit [N-1:0][7:0] r;
    for (int i = 0; i < n; i++) r[i] = 8'(i);
    return r;
  endfunction
  localparam bit [N-1:0][7:0] L = f(N);
  logic [C#(N)::sz()-1:0] w2;
  assign o = L;
endmodule
module top(output logic [5:0][7:0] o);
  sub #(.N(6)) u(.o(o));
endmodule
