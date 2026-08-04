interface abus;
  logic clk;
  logic dat;
  modport man (input clk, output dat);
  modport sub (output clk, input dat);
endinterface

interface zwrap (
  abus.man  m
);
  logic y;
endinterface

interface awrap (
  abus.sub  n
);
  logic x;
endinterface

module top();

abus  u_b();
zwrap u_zw (u_b.man);
awrap u_aw (u_b.sub);

endmodule
