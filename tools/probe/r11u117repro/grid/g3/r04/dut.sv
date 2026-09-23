// module-local localparams of the same shapes (control: module scope)
module top (output logic [7:0] a, b);
  localparam logic [7:0] M_CADD = {4'h1, 4'h2} + 1;
  localparam logic [7:0] M_ADD = 100 + 100;
  assign a = M_CADD;
  assign b = M_ADD;
endmodule
