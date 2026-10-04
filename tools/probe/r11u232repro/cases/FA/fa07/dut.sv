// § caCallArgParamFormalTs232
package q;
  function automatic int unsigned w(logic [7:0] x);
    return x + 1;
  endfunction
endpackage
module top(output logic [4:0] o);
  parameter int unsigned N = 4;
  logic [q::w(N)-1:0] v;
  assign v = '1;
  assign o = v;
endmodule
