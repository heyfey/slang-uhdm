// § evalFuncSelectKeepsCall148
package p; parameter logic [7:0] Q = 8'h3C; endpackage
module top(output logic o);
  function automatic logic f(); return p::Q[2]; endfunction
  assign o = f();
endmodule
