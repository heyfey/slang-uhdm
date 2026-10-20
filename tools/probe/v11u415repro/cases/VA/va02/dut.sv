// § labeledCallStmtLabelDropped415
module top(input logic [7:0] a, output logic [7:0] o);
  function automatic logic [7:0] f(input logic [7:0] x);
    l1: $display("%0d", x);
    return x + 1;
  endfunction
  assign o = f(a);
endmodule
