// § importNetTsDimEnd275 — a typedef with a packed dimension over it
package p;
  typedef logic [3:0] n_t;
  n_t [1:0] v;
endpackage
module dut (output logic [7:0] o);
  import p::*;
  assign o = v;
endmodule
