package cfgp;
  localparam logic [31:0] K = 32'hCAFE_F00D;
  parameter logic [15:0] PK2 = 16'h1234;
  localparam int N = 8;
  localparam logic [3:0][7:0] A2 = 32'h89AB_CDEF;
  localparam logic [1:0][1:0][3:0] A3 = 16'hBEEF;
  localparam logic [7:0] C = {4'hA, 4'h5};
endpackage
package sp;
  localparam logic [15:0] Q = 16'hA5C3;
  function automatic logic [7:0] g();
    return sp::Q[15:8];
  endfunction
endpackage
module top (output logic [7:0] o);
  assign o = sp::g();
endmodule
