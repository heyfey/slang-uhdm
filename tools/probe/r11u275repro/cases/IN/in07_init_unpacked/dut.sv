// § importNetTsDimEnd275 — an unpacked package variable with an initializer
package p;
  logic [7:0] v [0:1] = '{8'h1, 8'h2};
endpackage
module dut (output logic [7:0] o);
  import p::*;
  assign o = v[0];
endmodule
