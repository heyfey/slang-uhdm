// vb9 — a signed bound inside a FUNCTION BODY declaration.
module vb9 (input logic c, output logic o);
  localparam int          PS = 4;
  localparam int unsigned PU = 4;
  function automatic logic f(input logic a);
    logic [PS:0] ts;
    logic [PU:0] tu;
    ts = '0; tu = '0;
    return a ^ ts[0] ^ tu[0];
  endfunction
  assign o = f(c);
endmodule
