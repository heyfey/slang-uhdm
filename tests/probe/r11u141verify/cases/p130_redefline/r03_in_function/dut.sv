// § emptyRedefineObjLine130
// case r03: an empty redefinition inside a function body, lines after it
`define M
module top(input logic [3:0] a, output logic [3:0] y);
  function automatic logic [3:0] f(input logic [3:0] v);
`define M
    return v + 1;
  endfunction
  assign y = f(a);
endmodule
