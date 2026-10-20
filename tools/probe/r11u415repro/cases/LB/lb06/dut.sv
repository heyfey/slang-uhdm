// § labeledCallStmtLabelDropped415
module top(input logic [7:0] a, output logic [7:0] o);
  function automatic void f(input logic [7:0] x); endfunction
  always @(a) begin
    cf: f(a);
    o = a;
  end
endmodule
