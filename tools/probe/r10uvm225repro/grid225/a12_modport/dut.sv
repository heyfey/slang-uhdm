// r10uvm225 arm a12_modport — a MODPORT interface (the InterfaceModPort
// canary's shape) carrying containers, uninstantiated and instantiated.
typedef logic [7:0] tvp225_t;
class Cmp225;
  int x;
endclass

interface if225_mp(input logic clk225);
  logic [7:0] mp_data225;
  tvp225_t    mp_dyn225 [];
  tvp225_t    mp_as225  [string];
  tvp225_t    mp_fix225 [1:0];
  Cmp225      mp_dyncls225 [];
  modport master(input clk225, output mp_data225);
  modport slave(input clk225, input mp_data225);
endinterface

module top225_mp();
  logic clk225;
  if225_mp u_mp225(clk225);
endmodule
