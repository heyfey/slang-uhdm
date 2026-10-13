// § uninstIfaceForeachParamOwnTs304
interface ifc();
  typedef struct packed {logic [3:0] a;} s_t;
  parameter s_t P[2] = '{4'h1, 4'h2};
  function void f();
    foreach (P[i]) begin end
  endfunction
endinterface
module top; endmodule
