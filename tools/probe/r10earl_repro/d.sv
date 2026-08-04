package pd;
  parameter logic [3:0] A [2] = '{4'b0001, 2};
  parameter byte B [2] = '{8'h12, 5};
  parameter int C [2] = '{32'd7, 9};
  parameter logic [11:0] D [2] = '{12'h0ab, 3};
  parameter shortint E [2] = '{16'h00cd, 4};
  parameter logic [3:0] F [2] = '{'b1, 'h3};
endpackage
module md;
  parameter logic [3:0] MA [2] = '{4'b0001, 2};
  parameter byte MB [2] = '{8'h12, 5};
endmodule
