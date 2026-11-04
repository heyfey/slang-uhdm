// § labeledCallStmtLabelDropped415
module top(input logic [7:0] a, output logic [7:0] o);
  function automatic logic [7:0] f(input logic [7:0] x); return x; endfunction
  always @(a) begin
    cv: void'(f(a));
    o = a;
  end
endmodule
