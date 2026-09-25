// § streamOperandBraceSpan140
package p;
  function automatic logic [7:0] rev(input logic [7:0] v);
    return { << 2 {  v  } };
  endfunction
endpackage
module dut(input logic [7:0] x, output logic [7:0] y);
  assign y = p::rev(x);
endmodule
